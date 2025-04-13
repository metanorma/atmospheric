require "bigdecimal"
require "bigdecimal/math"
require "singleton"

module Atmospheric
  module Isa
    # International Standard Atmosphere (ISA) (ISO 2533:1975)
    # ICAO Standard Atmosphere (ICAO Doc 7488/3, 1994)

    class Algorithms
      attr_accessor :precision
      attr_reader :pressure_layers, :constants, :sqrt2, :pi

      def set_precision(precision)
        @precision = if precision == :high then :high else :normal end
        remove_instance_variable(:@pressure_layers) \
          if defined?(@pressure_layers)
        make_constants
      end

      # 2.3 Geopotential and geometric altitides; acceleration of free fall

      # 2.3 Formula (8)
      # H to h
      # h(m)
      def geometric_altitude_from_geopotential(geopotential_alt)
        @constants[:radius] * geopotential_alt \
          / (@constants[:radius] - geopotential_alt)
      end

      # 2.3 Formula (9)
      # h to H
      # H(m)
      def geopotential_altitude_from_geometric(geometric_alt)
        @constants[:radius] * geometric_alt \
          / (@constants[:radius] + geometric_alt)
      end

      # 2.3 Formula (7)
      # g(h)
      def gravity_at_geometric(geometric_alt)
        temp = @constants[:radius] / (@constants[:radius] + geometric_alt)
        @constants[:g_n] * temp * temp
      end

      def gravity_at_geopotential(geopotential_alt)
        geometric_h = geometric_altitude_from_geopotential(geopotential_alt)
        gravity_at_geometric(geometric_h)
      end

      # 2.4 Atmospheric composition and air molar mass

      # 2.5 Physical characteristics of the atmosphere at mean sea level

      # 2.6 Temperature and vertical temperature gradient

      # Formula (11)
      # T
      def temperature_at_layer_from_geopotential(geopotential_alt)
        lower_layer_index = locate_lower_layer(geopotential_alt)
        lower_layer = TEMPERATURE_LAYERS[lower_layer_index]
        beta = num(lower_layer[:B])
        capital_t_b = num(lower_layer[:T])
        capital_h_b = num(lower_layer[:H])

        capital_t_b + (beta * (geopotential_alt - capital_h_b))
      end

      def temperature_at_layer_celcius(geopotential_alt)
        kelvin_to_celsius(
          temperature_at_layer_from_geopotential(geopotential_alt),
        )
      end

      def locate_lower_layer(geopotential_alt)
        # Return first layer if lower than lowest
        return 0 if geopotential_alt < num(TEMPERATURE_LAYERS[0][:H])

        # Return second last layer if beyond last layer
        i = TEMPERATURE_LAYERS.length - 1
        return i - 1 if geopotential_alt >= num(TEMPERATURE_LAYERS[i][:H])

        # find last layer with H smaller than our H
        TEMPERATURE_LAYERS.each_with_index do |layer, ind|
          return ind - 1 if num(layer[:H]) > geopotential_alt
        end

        nil
      end

      # Table 4 - Temperature and vertical temperature gradients
      #
      TEMPERATURE_LAYERS = [
        # H is Geopotential altitude (base altitude) above mean sea level, m
        # T is Temperature, K
        # B is Temperature gradient, "beta", K m^-1

        # This line is from ICAO 7488/3
        # { H: "-5000", T: "320.65", B: "-0.0065" },

        # This line is from ISO 2533:1975
        { H: "-2000", T: "301.15", B: "-0.0065" },
        { H: "0",     T: "288.15", B: "-0.0065" },
        { H: "11000", T: "216.65", B: "0"       },
        { H: "20000", T: "216.65", B: "0.001"   },
        { H: "32000", T: "228.65", B: "0.0028"  },
        { H: "47000", T: "270.65", B: "0"       },
        { H: "51000", T: "270.65", B: "-0.0028" },
        { H: "71000", T: "214.65", B: "-0.002"  },
        { H: "80000", T: "196.65" },
      ].freeze

      # 2.7 Pressure

      # Base pressure values given defined `TEMPERATURE_LAYERS` and constants
      def pressure_layers
        return @pressure_layers if @pressure_layers

        # assume TEMPERATURE_LAYERS index 1 base altitude is 0 (mean sea level)
        p = []

        TEMPERATURE_LAYERS.each_with_index do |_x, i|
          last_i = i.zero? ? 0 : i - 1
          last_layer = TEMPERATURE_LAYERS[last_i]
          beta = num(last_layer[:B])

          if num(last_layer[:H]) <= 0
            p_b = @constants[:p_n]
            capital_h_b = 0
            capital_t_b = @constants[:T_n]
          else
            p_b = p[last_i]
            capital_h_b = num(last_layer[:H])
            capital_t_b = num(last_layer[:T])
          end

          current_layer = TEMPERATURE_LAYERS[i]
          geopotential_alt = num(current_layer[:H])
          temp = num(current_layer[:T])
          height_diff = geopotential_alt - capital_h_b

          p_i = if beta == 0
                  # Formula (13)
                  pressure_formula_beta_zero(p_b, temp, height_diff)
                else
                  # Formula (12)
                  pressure_formula_beta_nonzero(p_b, beta, capital_t_b,
                                                height_diff)
                end
          p[i] = p_i
        end

        @pressure_layers = p
      end

      # Formula (12)
      def pressure_formula_beta_nonzero(p_b, beta, temp, height_diff)
        p_b * (1 + ((beta / temp) * height_diff)) \
          **(-@constants[:g_n] / (beta * @constants[:R]))
      end

      # Formula (13)
      def pressure_formula_beta_zero(p_b, temp, height_diff)
        p_b *
          Math.exp(-(@constants[:g_n] / (@constants[:R] * temp)) * height_diff)
      end

      # puts "PRE-CALCULATED PRESSURE LAYERS:"
      # pp @pressure_layers

      def pa_to_mmhg(pascal)
        pascal * num("0.007500616827")
      end

      def pa_to_mbar(pascal)
        pascal * num("0.01")
      end

      # Pressure for a given geopotential altitude `H` (m) above mean sea level
      def pressure_from_geopotential(geopotential_alt)
        i = locate_lower_layer(geopotential_alt)
        lower_temperature_layer = TEMPERATURE_LAYERS[i]
        beta = num(lower_temperature_layer[:B])
        capital_h_b = num(lower_temperature_layer[:H])
        capital_t_b = num(lower_temperature_layer[:T])
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p_b = pressure_layers[i]
        height_diff = geopotential_alt - capital_h_b

        if beta == 0
          # Formula (13)
          pressure_formula_beta_zero(p_b, temp, height_diff)
        else
          # Formula (12)
          pressure_formula_beta_nonzero(p_b, beta, capital_t_b, height_diff)
        end
      end

      def pressure_from_geopotential_mbar(geopotential_alt)
        pa_to_mbar(pressure_from_geopotential(geopotential_alt))
      end

      def pressure_from_geopotential_mmhg(geopotential_alt)
        pa_to_mmhg(pressure_from_geopotential(geopotential_alt))
      end

      def p_p_n_from_geopotential(geopotential_alt)
        pressure_from_geopotential(geopotential_alt) / @constants[:p_n]
      end

      # 2.8 Density and specific weight

      # Density for a given geopotential altitude `H` (m) above mean sea level
      # Formula (14)
      # rho
      def density_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p = pressure_from_geopotential(geopotential_alt)

        p / (@constants[:R] * temp)
      end

      def rho_rho_n_from_geopotential(geopotential_alt)
        density_from_geopotential(geopotential_alt) / @constants[:rho_n]
      end

      def root_rho_rho_n_from_geopotential(geopotential_alt)
        sqrt(rho_rho_n_from_geopotential(geopotential_alt))
      end

      # Specific weight
      # Formula (15)
      # gamma
      def specific_weight_from_geopotential(geopotential_alt)
        density_from_geopotential(geopotential_alt) *
          gravity_at_geopotential(geopotential_alt)
      end

      # 2.9 Pressure scale height
      # Formula (16)
      # H_p
      def pressure_scale_height_from_temp(temp)
        (@constants[:R] * temp) / @constants[:g_n]
      end

      def pressure_scale_height_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        (@constants[:R] * temp) / gravity_at_geopotential(geopotential_alt)
      end

      # 2.10 Air number density
      # Formula (17)
      # n
      def air_number_density_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p = pressure_from_geopotential(geopotential_alt)

        @constants[:N_A] * p / (@constants[:R_star] * temp)
      end

      # 2.11 Mean air-particle speed
      # Formula (18)
      # v_bar
      # CORRECT
      def mean_air_particle_speed_from_temp(temp)
        num("1.595769") * sqrt(@constants[:R] * temp)
      end

      def mean_air_particle_speed_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        mean_air_particle_speed_from_temp(temp)
      end

      # 2.12 Mean free path of air particles
      # Formula (19)
      # l
      def mean_free_path_of_air_particles_from_geopotential(geopotential_alt)
        # 1 / (sqrt(2) * Pi * (3.65e-10**2) * air_number_density
        1 / (@sqrt2 * @pi * num("0.133225e-18") * \
          air_number_density_from_geopotential(geopotential_alt))
      end

      # 2.13 Air-particle collision frequency
      # Formula (20)
      # omega
      def air_particle_collision_frequency_from_temp(air_number_density, temp)
        # 4 * (3.65e-10**2) * ...
        4 * num("0.133225e-18") *
          ((@pi / (@constants[:R_star] * @constants[:M]))**num("0.5")) *
          air_number_density * @constants[:R_star] * (temp**num("0.5"))
      end

      def air_particle_collision_frequency_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        n = air_number_density_from_geopotential(geopotential_alt)
        air_particle_collision_frequency_from_temp(n, temp)
      end

      # 2.14 Speed of sound
      # Formula (21)
      # a (ms-1)
      # CORRECT
      def speed_of_sound_from_temp(temp)
        # `kappa` (ratio of c_p / c_v) = 1.4 (see 2.14)
        kappa = num("1.4")
        sqrt(kappa * @constants[:R] * temp)
      end

      def speed_of_sound_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        speed_of_sound_from_temp(temp)
      end

      # 2.15 Dynamic viscosity
      # Formula (22)
      # mu (Pa s)
      def dynamic_viscosity(temp)
        # Sutherland's empirical constants in the equation for dynamic viscosity
        capital_b_s = num("1.458e-6")
        capital_s = num("110.4")

        (capital_b_s * (temp**num("1.5"))) / (temp + capital_s)
      end

      def dynamic_viscosity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        dynamic_viscosity(temp)
      end

      # 2.16 Kinematic viscosity
      # Formula (23)
      # v
      def kinematic_viscosity(temp)
        dynamic_viscosity(temp) / @constants[:rho_n]
      end

      def kinematic_viscosity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        dynamic_viscosity(temp) / density_from_geopotential(geopotential_alt)
      end

      # 2.17 Thermal conductivity
      # Formula (24)
      # lambda
      def thermal_conductivity_from_temp(temp)
        (num("2.648151e-3") * (temp**num("1.5"))) \
          / (temp + (num("245.4") * (num("10")**(num("-12") / temp))))
      end

      def thermal_conductivity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        thermal_conductivity_from_temp(temp)
      end

      def kelvin_to_celsius(kelvin)
        kelvin - num("273.15")
      end

      # ADD 1
      # Formulae used in the calculation of the relationships
      # between geopotential altitude and pressure
      def geopotential_altitude_from_pressure_mbar(pressure)
        if pressure >= pa_to_mbar(pressure_layers[2]) # H <= 11 000 m
          (num("3.731444") - pressure**num("0.1902631")) / num("8.41728e-5")
        elsif pressure >= pa_to_mbar(pressure_layers[3]) # H <= 20 000 m
          (num("3.1080387") - log10(pressure)) / num("6.848325e-5")
        elsif pressure >= pa_to_mbar(pressure_layers[4]) # H <= 32 000 m
          (num("1.2386515") - pressure**num("0.02927125")) \
/ (num("5.085177e-6") * pressure**num("0.02927125"))
        elsif pressure >= pa_to_mbar(pressure_layers[5]) # H <= 47 000 m
          (num("1.9630052") - pressure**num("0.08195949")) \
/ (num("2.013664e-5") * pressure**num("0.08195949"))
        end
      end

      def geopotential_altitude_from_pressure_mmhg(pressure)
        if pressure >= pa_to_mmhg(pressure_layers[2]) # H <= 11 000 m
          (num("3.532747") - pressure**num("0.1902631")) / num("7.96906e-5")
        elsif pressure >= pa_to_mmhg(pressure_layers[3]) # H <= 20 000 m
          (num("2.9831357") - log10(pressure)) / num("6.848325e-5")
        elsif pressure >= pa_to_mmhg(pressure_layers[4]) # H <= 32 000 m
          (num("1.2282678") - pressure**num("0.02927125")) \
            / (num("5.085177e-6") * pressure**num("0.02927125"))
        elsif pressure >= pa_to_mmhg(pressure_layers[5]) # H <= 47 000 m
          (num("1.9172753") - pressure**num("0.08195949")) \
            / (num("2.013664e-5") * pressure**num("0.08195949"))
        end
      end

      def mbar_to_mmhg(mbar)
        # Convert mbar to Pa, then Pa to mmHg
        pa = mbar / num("0.01") # or mbar * 100
        pa_to_mmhg(pa)
      end

      def mmhg_to_mbar(mmhg)
        # Convert mmHg to Pa, then Pa to mbar
        pa = mmhg / num("0.007500616827")
        pa_to_mbar(pa)
      end

      private

      def num(str)
        if @precision == :high
          BigDecimal(str)
        else
          str.to_f
        end
      end

      def sqrt(num)
        if @precision == :high
          BigMath.sqrt(num, 100)
        else
          Math.sqrt(num)
        end
      end

      def log10(num)
        if @precision == :high
          BigMath.log(num, 100) / BigMath.log(10, 100)
        else
          Math.log10(num)
        end
      end

      def make_constants
        # 2.1 Primary constants and characteristics
        # Table 1 - Main constants and characteristics adopted for
        #           the calculation of the ISO Standard Atmosphere
        @constants = {
          # g_n gravitation at mean sea level (m.s-2)
          g_n: num("9.80665"),

          # Avogadro constant (mol-1)
          N_A: num("6.02257e+23"),

          # p_n pressure at mean sea level (Pa)
          p_n: num("101325"),

          # rho_n standard air density
          rho_n: num("1.225"),

          # T_n standard thermodynamic air temperature at mean sea level
          T_n: num("288.15"),

          # universal gas constant
          R_star: num("8.31432"),

          # radius of the Earth (m)
          radius: num("6356766"),

          # adiabatic index (dimensionless)
          k: num("1.4"),
        }

        # 2.2 The equation of the static atmosphere and the perfect gas law
        # Formula (2)
        # M: air molar mass at sea level, kg.kmol-1
        # Value given in 2.1 as M: 28.964720
        @constants[:M] =
          (@constants[:rho_n] * @constants[:R_star] * @constants[:T_n]) / @constants[:p_n]

        # Formula (3)
        # R: specific gas constant, J.K-1.kg-1.
        # Value given in 2.1 as R: 287.05287
        @constants[:R] = @constants[:R_star] / @constants[:M]

        @sqrt2 = sqrt(num("2"))
        @pi = if @precision == :high then BigMath.PI(100) else Math::PI end
      end
    end

    class HighPrecision < Algorithms
      include Singleton

      def initialize
        set_precision(:high)
      end
    end

    class NormalPrecision < Algorithms
      include Singleton

      def initialize
        set_precision(:normal)
      end
    end
  end
end
