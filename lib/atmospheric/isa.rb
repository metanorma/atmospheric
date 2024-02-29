module Atmospheric
  module Isa
    # International Standard Atmosphere (ISA) (ISO 2533:1975)
    # ICAO Standard Atmosphere (ICAO Doc 7488/3, 1994)

    # 2.1 Primary constants and characteristics
    # Table 1 - Main constants and characteristics adopted for
    #           the calculation of the ISO Standard Atmosphere
    constants = {
      # g_n gravitation at mean sea level (m.s-2)
      g_n: 9.80665,

      # Avogadro constant (mol-1)
      N_A: 6.02257e+23,

      # p_n pressure at mean sea level (Pa)
      p_n: 101325,

      # rho_n standard air density
      rho_n: 1.225,

      # T_n standard thermodynamic air temperature at mean sea level
      T_n: 288.15,

      # universal gas constant
      R_star: 8.31432,

      # radius of the Earth (m)
      radius: 6356766,

      # adiabatic index (dimensionless)
      k: 1.4,
    }

    # 2.2 The equation of the static atmosphere and the perfect gas law
    # Formula (2)
    # M: air molar mass at sea level, kg.kmol-1
    # Value given in 2.1 as M: 28.964720
    constants[:M] =
      (constants[:rho_n] * constants[:R_star] * constants[:T_n]) \
        / constants[:p_n]

    # Formula (3)
    # R: specific gas constant, J.K-1.kg-1.
    # Value given in 2.1 as R: 287.05287
    constants[:R] = constants[:R_star] / constants[:M]

    CONST = constants.freeze

    class << self
      # 2.3 Geopotential and geometric altitides; acceleration of free fall

      # 2.3 Formula (8)
      # H to h
      # h(m)
      def geometric_altitude_from_geopotential(geopotential_alt)
        CONST[:radius] * geopotential_alt / (CONST[:radius] - geopotential_alt)
      end

      # 2.3 Formula (9)
      # h to H
      # H(m)
      def geopotential_altitude_from_geometric(geometric_alt)
        CONST[:radius] * geometric_alt / (CONST[:radius] + geometric_alt)
      end

      # 2.3 Formula (7)
      # g(h)
      def gravity_at_geometric(geometric_alt)
        temp = CONST[:radius] / (CONST[:radius] + geometric_alt)
        CONST[:g_n] * temp * temp
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
        beta = lower_layer[:B]
        capital_t_b = lower_layer[:T]
        capital_h_b = lower_layer[:H]

        capital_t_b + (beta * (geopotential_alt - capital_h_b))
      end

      def temperature_at_layer_celcius(geopotential_alt)
        kelvin_to_celsius(
          temperature_at_layer_from_geopotential(geopotential_alt),
        )
      end

      def locate_lower_layer(geopotential_alt)
        # Return first layer if lower than lowest
        return 0 if geopotential_alt < TEMPERATURE_LAYERS[0][:H]

        # Return second last layer if beyond last layer
        i = TEMPERATURE_LAYERS.length - 1
        return i - 1 if geopotential_alt >= TEMPERATURE_LAYERS[i][:H]

        # find last layer with H smaller than our H
        TEMPERATURE_LAYERS.each_with_index do |layer, ind|
          return ind - 1 if layer[:H] > geopotential_alt
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
        # [H: -5000, T: 320.65, B: -0.0065 ],

        # This line is from ISO 2533:1975
        { H: -2000, T: 301.15, B: -0.0065 },
        { H: 0,     T: 288.15, B: -0.0065 },
        { H: 11000, T: 216.65, B: 0       },
        { H: 20000, T: 216.65, B: 0.001   },
        { H: 32000, T: 228.65, B: 0.0028  },
        { H: 47000, T: 270.65, B: 0       },
        { H: 51000, T: 270.65, B: -0.0028 },
        { H: 71000, T: 214.65, B: -0.002  },
        { H: 80000, T: 196.65 },
      ].freeze

      # 2.7 Pressure

      # Base pressure values given defined `TEMPERATURE_LAYERS` and constants
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/MethodLength
      def pressure_layers
        return @pressure_layers if @pressure_layers

        # assume TEMPERATURE_LAYERS index 1 base altitude is 0 (mean sea level)
        p = []

        TEMPERATURE_LAYERS.each_with_index do |_x, i|
          last_i = i.zero? ? 0 : i - 1
          last_layer = TEMPERATURE_LAYERS[last_i]
          beta = last_layer[:B]

          if last_layer[:H] <= 0
            p_b = CONST[:p_n]
            capital_h_b = 0
            capital_t_b = CONST[:T_n]
          else
            p_b = p[last_i]
            capital_h_b = last_layer[:H]
            capital_t_b = last_layer[:T]
          end

          current_layer = TEMPERATURE_LAYERS[i]
          geopotential_alt = current_layer[:H]
          temp = current_layer[:T]
          height_diff = geopotential_alt - capital_h_b

          p_i = if beta != 0
                  # Formula (12)
                  pressure_formula_beta_nonzero(p_b, beta, capital_t_b,
                                                height_diff)
                else
                  # Formula (13)
                  pressure_formula_beta_zero(p_b, temp, height_diff)
                end
          p[i] = p_i
        end

        @pressure_layers = p
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength

      # Formula (12)
      def pressure_formula_beta_nonzero(p_b, beta, temp, height_diff)
        p_b * (1 + ((beta / temp) * height_diff)) \
          **(-CONST[:g_n] / (beta * CONST[:R]))
      end

      # Formula (13)
      def pressure_formula_beta_zero(p_b, temp, height_diff)
        p_b * Math.exp(-(CONST[:g_n] / (CONST[:R] * temp)) * height_diff)
      end

      # puts "PRE-CALCULATED PRESSURE LAYERS:"
      # pp @pressure_layers

      def pa_to_mmhg(pascal)
        pascal * 0.007500616827
      end

      def pa_to_mbar(pascal)
        pascal * 0.01
      end

      # rubocop:disable Metrics/MethodLength
      # Pressure for a given geopotential altitude `H` (m) above mean sea level
      def pressure_from_geopotential(geopotential_alt)
        i = locate_lower_layer(geopotential_alt)
        lower_temperature_layer = TEMPERATURE_LAYERS[i]
        beta = lower_temperature_layer[:B]
        capital_h_b = lower_temperature_layer[:H]
        capital_t_b = lower_temperature_layer[:T]
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p_b = pressure_layers[i]
        height_diff = geopotential_alt - capital_h_b

        if beta != 0
          # Formula (12)
          pressure_formula_beta_nonzero(p_b, beta, capital_t_b, height_diff)
        else
          # Formula (13)
          pressure_formula_beta_zero(p_b, temp, height_diff)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def pressure_from_geopotential_mbar(geopotential_alt)
        pa_to_mbar(pressure_from_geopotential(geopotential_alt))
      end

      def pressure_from_geopotential_mmhg(geopotential_alt)
        pa_to_mmhg(pressure_from_geopotential(geopotential_alt))
      end

      def p_p_n_from_geopotential(geopotential_alt)
        pressure_from_geopotential(geopotential_alt) / CONST[:p_n]
      end

      # 2.8 Density and specific weight

      # Density for a given geopotential altitude `H` (m) above mean sea level
      # Formula (14)
      # rho
      def density_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p = pressure_from_geopotential(geopotential_alt)

        p / (CONST[:R] * temp)
      end

      def rho_rho_n_from_geopotential(geopotential_alt)
        density_from_geopotential(geopotential_alt) / CONST[:rho_n]
      end

      def root_rho_rho_n_from_geopotential(geopotential_alt)
        Math.sqrt(rho_rho_n_from_geopotential(geopotential_alt))
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
        (CONST[:R] * temp) / CONST[:g_n]
      end

      def pressure_scale_height_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        (CONST[:R] * temp) / gravity_at_geopotential(geopotential_alt)
      end

      # 2.10 Air number density
      # Formula (17)
      # n
      def air_number_density_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p = pressure_from_geopotential(geopotential_alt)

        CONST[:N_A] * p / (CONST[:R_star] * temp)
      end

      # 2.11 Mean air-particle speed
      # Formula (18)
      # v_bar
      # CORRECT
      def mean_air_particle_speed_from_temp(temp)
        1.595769 * Math.sqrt(CONST[:R] * temp)
      end

      def mean_air_particle_speed_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        mean_air_particle_speed_from_temp(temp)
      end

      # 2.12 Mean free path of air particles
      # Formula (19)
      # l
      def mean_free_path_of_air_particles_from_geopotential(geopotential_alt)
        1 / (1.414213562 * 3.141592654 * (3.65e-10**2) * \
          air_number_density_from_geopotential(geopotential_alt))
      end

      # 2.13 Air-particle collision frequency
      # Formula (20)
      # omega
      def air_particle_collision_frequency_from_temp(air_number_density, temp)
        4 * (3.65e-10**2) *
          ((3.141592654 / (CONST[:R_star] * CONST[:M]))**0.5) *
          air_number_density * CONST[:R_star] * (temp**0.5)
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
        kappa = 1.4
        Math.sqrt(kappa * CONST[:R] * temp)
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
        capital_b_s = 1.458e-6
        capital_s = 110.4

        (capital_b_s * (temp**1.5)) / (temp + capital_s)
      end

      def dynamic_viscosity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        dynamic_viscosity(temp)
      end

      # 2.16 Kinematic viscosity
      # Formula (23)
      # v
      def kinematic_viscosity(temp)
        dynamic_viscosity(temp) / CONST[:rho_n]
      end

      def kinematic_viscosity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        dynamic_viscosity(temp) / density_from_geopotential(geopotential_alt)
      end

      # 2.17 Thermal conductivity
      # Formula (24)
      # lambda
      def thermal_conductivity_from_temp(temp)
        (2.648151e-3 * (temp**1.5)) / (temp + (245.4 * (10**(-12.0 / temp))))
      end

      def thermal_conductivity_from_geopotential(geopotential_alt)
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        thermal_conductivity_from_temp(temp)
      end

      def kelvin_to_celsius(kelvin)
        kelvin - 273.15
      end
    end
  end
end
