# frozen_string_literal: true

module Atmospheric
  module Export
    class AltitudeAttrs < Lutaml::Model::Serializable
      include AltitudeConvertableModel

      # From Group One
      attribute :temperatures, UnitValueFloat, collection: true
      attribute :pressures, UnitValueFloat, collection: true
      attribute :densities, UnitValueFloat, collection: true
      attribute :accelerations, UnitValueFloat, collection: true

      # From Group Two
      attribute :ppns, UnitValueFloat, collection: true
      attribute :rhorhons, UnitValueFloat, collection: true
      attribute :sqrt_rhorhons, UnitValueFloat, collection: true
      attribute :speeds_of_sound, UnitValueFloat, collection: true
      attribute :dynamic_viscosities, UnitValueFloat, collection: true
      attribute :kinematic_viscosities, UnitValueFloat, collection: true
      attribute :thermal_conductivities, UnitValueFloat, collection: true

      # From Group Three
      attribute :pressure_scale_heights, UnitValueFloat, collection: true
      attribute :specific_weights, UnitValueFloat, collection: true
      attribute :air_number_densities, UnitValueFloat, collection: true
      attribute :mean_speeds, UnitValueFloat, collection: true
      attribute :frequencies, UnitValueFloat, collection: true
      attribute :mean_free_paths, UnitValueFloat, collection: true
      attribute :precision, PrecisionValue

      key_value do
        map "geometric-altitude", to: :geometric_altitudes
        map "geopotential-altitude", to: :geopotential_altitudes

        # From Group One
        map "temperature", to: :temperatures
        map "pressure", to: :pressures
        map "density", to: :densities
        map "acceleration", to: :accelerations

        # From Group Two
        map "ppn", to: :ppns
        map "rhorhon", to: :rhorhons
        map "sqrt-rhorhon", to: :sqrt_rhorhons
        map "speed-of-sound", to: :speeds_of_sound
        map "dynamic-viscosity", to: :dynamic_viscosities
        map "kinematic-viscosity", to: :kinematic_viscosities
        map "thermal-conductivity", to: :thermal_conductivities

        # From Group Three
        map "pressure-scale-height", to: :pressure_scale_heights
        map "specific-weight", to: :specific_weights
        map "air-number-density", to: :air_number_densities
        map "mean-speed", to: :mean_speeds
        map "frequency", to: :frequencies
        map "mean-free-path", to: :mean_free_paths

        map "precision", to: :precision
      end

      xml do
        element "atmosphere-attributes"
        namespace Atmospheric::Iso2533Namespace
        map_element "geometric-altitude", to: :geometric_altitudes
        map_element "geopotential-altitude", to: :geopotential_altitudes

        # From Group One
        map_element "temperature", to: :temperatures
        map_element "pressure", to: :pressures
        map_element "density", to: :densities
        map_element "acceleration", to: :accelerations

        # From Group Two
        map_element "ppn", to: :ppns
        map_element "rhorhon", to: :rhorhons
        map_element "sqrt-rhorhon", to: :sqrt_rhorhons
        map_element "speed-of-sound", to: :speeds_of_sound
        map_element "dynamic-viscosity", to: :dynamic_viscosities
        map_element "kinematic-viscosity", to: :kinematic_viscosities
        map_element "thermal-conductivity", to: :thermal_conductivities

        # From Group Three
        map_element "pressure-scale-height", to: :pressure_scale_heights
        map_element "specific-weight", to: :specific_weights
        map_element "air-number-density", to: :air_number_densities
        map_element "mean-speed", to: :mean_speeds
        map_element "frequency", to: :frequencies
        map_element "mean-free-path", to: :mean_free_paths

        map_element "precision", to: :precision
      end

      # In meters only
      def realize_values_from_geopotential(gp_h_m, precision: :reduced)
        self.precision = precision.to_s

        # Group One
        self.temperatures = [
          calculate(gp_h_m, :temperature_k, precision: precision),
          calculate(gp_h_m, :temperature_c, precision: precision)
        ]

        self.pressures = [
          calculate(gp_h_m, :pressure_mbar, precision: precision),
          calculate(gp_h_m, :pressure_mmhg, precision: precision)
        ]

        self.densities = [
          calculate(gp_h_m, :density, precision: precision)
        ]

        self.accelerations = [
          calculate(gp_h_m, :acceleration, precision: precision)
        ]

        # Group Two
        self.ppns = [
          calculate(gp_h_m, :ppn, precision: precision)
        ]

        self.rhorhons = [
          calculate(gp_h_m, :rhorhon, precision: precision)
        ]

        self.sqrt_rhorhons = [
          calculate(gp_h_m, :sqrt_rhorhon, precision: precision)
        ]

        self.speeds_of_sound = [
          calculate(gp_h_m, :speed_of_sound, precision: precision)
        ]

        self.dynamic_viscosities = [
          calculate(gp_h_m, :dynamic_viscosity, precision: precision)
        ]

        self.kinematic_viscosities = [
          calculate(gp_h_m, :kinematic_viscosity, precision: precision)
        ]

        self.thermal_conductivities = [
          calculate(gp_h_m, :thermal_conductivity, precision: precision)
        ]

        # Group Three
        self.pressure_scale_heights = [
          calculate(gp_h_m, :pressure_scale_height, precision: precision)
        ]

        self.specific_weights = [
          calculate(gp_h_m, :specific_weight, precision: precision)
        ]

        self.air_number_densities = [
          calculate(gp_h_m, :air_number_density, precision: precision)
        ]

        self.mean_speeds = [
          calculate(gp_h_m, :mean_speed, precision: precision)
        ]

        self.frequencies = [
          calculate(gp_h_m, :frequency, precision: precision)
        ]

        self.mean_free_paths = [
          calculate(gp_h_m, :mean_free_path, precision: precision)
        ]
      end

      def calculate(gp_h_m, name, precision: :reduced)
        isa = precision == :high ? Isa::HighPrecision.instance : Isa::NormalPrecision.instance

        case name
        when :temperature_k
          v = isa.temperature_at_layer_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "K"
          )
        when :temperature_c
          v = isa.temperature_at_layer_celcius(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "degC"
          )
        when :pressure_mbar
          v = isa.pressure_from_geopotential_mbar(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "mbar"
          )
        when :pressure_mmhg
          v = isa.pressure_from_geopotential_mmhg(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "mm_Hg"
          )
        when :density
          v = isa.density_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "kg*m^-3"
          )
        when :acceleration
          v = isa.gravity_at_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(4) : v,
            unitsml: "m*s^-2"
          )
        when :ppn
          v = isa.p_p_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :rhorhon
          v = isa.rho_rho_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :sqrt_rhorhon
          v = isa.root_rho_rho_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :speed_of_sound
          v = isa.speed_of_sound_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "m*s^-1"
          )
        when :dynamic_viscosity
          v = isa.dynamic_viscosity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "Pa*s"
          )
        when :kinematic_viscosity
          v = isa.kinematic_viscosity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "m^2*s^-1"
          )
        when :thermal_conductivity
          v = isa.thermal_conductivity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "W*m^-1*K^-1"
          )
        when :pressure_scale_height
          v = isa.pressure_scale_height_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(1) : v,
            unitsml: "m"
          )
        when :specific_weight
          v = isa.specific_weight_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "N*m^-3"
          )
        when :air_number_density
          v = isa.air_number_density_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "m^-3"
          )
        when :mean_speed
          v = isa.mean_air_particle_speed_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(2) : v,
            unitsml: "m*s^-1"
          )
        when :frequency
          v = isa.air_particle_collision_frequency_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "s^-1"
          )
        when :mean_free_path
          v = isa.mean_free_path_of_air_particles_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "m"
          )
        else
          raise ArgumentError, "Unknown attribute: #{name}"
        end
      end
    end
  end
end
