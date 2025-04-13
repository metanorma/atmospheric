# frozen_string_literal: true

require "lutaml/model"
require_relative "../unit_value_float"
require_relative "../unit_value_integer"

module Atmospheric
  module Export
    class AltitudeAttrs < Lutaml::Model::Serializable
      include AltitudeConvertableModel

      # From Group One
      attribute :temperature_k, UnitValueInteger
      attribute :temperature_c, UnitValueInteger
      attribute :pressure_mbar, UnitValueFloat
      attribute :pressure_mmhg, UnitValueFloat
      attribute :density, UnitValueFloat
      attribute :acceleration, UnitValueFloat

      # From Group Two
      attribute :ppn, UnitValueFloat
      attribute :rhorhon, UnitValueFloat
      attribute :sqrt_rhorhon, UnitValueFloat
      attribute :speed_of_sound, UnitValueInteger
      attribute :dynamic_viscosity, UnitValueFloat
      attribute :kinematic_viscosity, UnitValueFloat
      attribute :thermal_conductivity, UnitValueFloat

      # From Group Three
      attribute :pressure_scale_height, UnitValueFloat
      attribute :specific_weight, UnitValueFloat
      attribute :air_number_density, UnitValueFloat
      attribute :mean_speed, UnitValueFloat
      attribute :frequency, UnitValueFloat
      attribute :mean_free_path, UnitValueFloat

      key_value do
        map "geometric-altitude-m", to: :geometric_altitude_m
        map "geometric-altitude-ft", to: :geometric_altitude_ft
        map "geopotential-altitude-m", to: :geopotential_altitude_m
        map "geopotential-altitude-ft", to: :geopotential_altitude_ft

        # From Group One
        map "temperature-k", to: :temperature_k
        map "temperature-c", to: :temperature_c
        map "pressure-mbar", to: :pressure_mbar
        map "pressure-mmhg", to: :pressure_mmhg
        map "density", to: :density
        map "acceleration", to: :acceleration

        # From Group Two
        map "ppn", to: :ppn
        map "rhorhon", to: :rhorhon
        map "sqrt-rhorhon", to: :sqrt_rhorhon
        map "speed-of-sound", to: :speed_of_sound
        map "dynamic-viscosity", to: :dynamic_viscosity
        map "kinematic-viscosity", to: :kinematic_viscosity
        map "thermal-conductivity", to: :thermal_conductivity

        # From Group Three
        map "pressure-scale-height", to: :pressure_scale_height
        map "specific-weight", to: :specific_weight
        map "air-number-density", to: :air_number_density
        map "mean-speed", to: :mean_speed
        map "frequency", to: :frequency
        map "mean-free-path", to: :mean_free_path
      end

      xml do
        root "atmosphere-attributes"
        map_element "geometric-altitude-m", to: :geometric_altitude_m
        map_element "geometric-altitude-ft", to: :geometric_altitude_ft
        map_element "geopotential-altitude-m", to: :geopotential_altitude_m
        map_element "geopotential-altitude-ft", to: :geopotential_altitude_ft

        # From Group One
        map_element "temperature-k", to: :temperature_k
        map_element "temperature-c", to: :temperature_c
        map_element "pressure-mbar", to: :pressure_mbar
        map_element "pressure-mmhg", to: :pressure_mmhg
        map_element "density", to: :density
        map_element "acceleration", to: :acceleration

        # From Group Two
        map_element "ppn", to: :ppn
        map_element "rhorhon", to: :rhorhon
        map_element "sqrt-rhorhon", to: :sqrt_rhorhon
        map_element "speed-of-sound", to: :speed_of_sound
        map_element "dynamic-viscosity", to: :dynamic_viscosity
        map_element "kinematic-viscosity", to: :kinematic_viscosity
        map_element "thermal-conductivity", to: :thermal_conductivity

        # From Group Three
        map_element "pressure-scale-height", to: :pressure_scale_height
        map_element "specific-weight", to: :specific_weight
        map_element "air-number-density", to: :air_number_density
        map_element "mean-speed", to: :mean_speed
        map_element "frequency", to: :frequency
        map_element "mean-free-path", to: :mean_free_path
      end

      # In meters only
      def realize_values_from_geopotential(gp_h_m, precision: :reduced)
        %i[
          temperature_k temperature_c pressure_mbar pressure_mmhg density
          acceleration ppn rhorhon sqrt_rhorhon speed_of_sound
          dynamic_viscosity kinematic_viscosity thermal_conductivity
          pressure_scale_height specific_weight air_number_density mean_speed
          frequency mean_free_path
        ].each do |attr|
          v = calculate(gp_h_m, attr, precision: precision)
          send("#{attr}=", v) if respond_to?("#{attr}=")
        end
      end

      def calculate(gp_h_m, name, precision: :reduced)
        case name
        when :temperature_k
          v = Isa::NormalPrecision.instance.temperature_at_layer_from_geopotential(gp_h_m)
          UnitValueInteger.new(
            value: precision == :reduced ? (v * 1000.0).round : v,
            unitsml: "K"
          )
        when :temperature_c
          v = Isa::NormalPrecision.instance.temperature_at_layer_celcius(gp_h_m)
          UnitValueInteger.new(
            value: precision == :reduced ? (v * 1000.0).round : v,
            unitsml: "degC"
          )
        when :pressure_mbar
          v = Isa::NormalPrecision.instance.pressure_from_geopotential_mbar(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "mbar"
          )
        when :pressure_mmhg
          v = Isa::NormalPrecision.instance.pressure_from_geopotential_mmhg(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "u:mm_Hg"
          )
        when :density
          v = Isa::NormalPrecision.instance.density_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: "kg*m^-3"
          )
        when :acceleration
          v = Isa::NormalPrecision.instance.gravity_at_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(4) : v,
            unitsml: "m*s^-2"
          )
        when :ppn
          v = Isa::NormalPrecision.instance.p_p_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :rhorhon
          v = Isa::NormalPrecision.instance.rho_rho_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :sqrt_rhorhon
          v = Isa::NormalPrecision.instance.root_rho_rho_n_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
            unitsml: nil
          )
        when :speed_of_sound
          v = Isa::NormalPrecision.instance.speed_of_sound_from_geopotential(gp_h_m)
          UnitValueInteger.new(
            value: precision == :reduced ? (v * 1000.0).round : v,
            unitsml: "m*s^-1"
          )
        when :dynamic_viscosity
          v = Isa::NormalPrecision.instance.dynamic_viscosity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "Pa*s"
          )
        when :kinematic_viscosity
          v = Isa::NormalPrecision.instance.kinematic_viscosity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "m^2*s^-1"
          )
        when :thermal_conductivity
          v = Isa::NormalPrecision.instance.thermal_conductivity_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "W*m^-1*K^-1"
          )
        when :pressure_scale_height
          v = Isa::NormalPrecision.instance.pressure_scale_height_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(1) : v,
            unitsml: "m"
          )
        when :specific_weight
          v = Isa::NormalPrecision.instance.specific_weight_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "N*m^-3"
          )
        when :air_number_density
          v = Isa::NormalPrecision.instance.air_number_density_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "m^-3"
          )
        when :mean_speed
          v = Isa::NormalPrecision.instance.mean_air_particle_speed_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? v.round(2) : v,
            unitsml: "m*s^-1"
          )
        when :frequency
          v = Isa::NormalPrecision.instance.air_particle_collision_frequency_from_geopotential(gp_h_m)
          UnitValueFloat.new(
            value: precision == :reduced ? round_to_sig_figs(v, 5) : v,
            unitsml: "s^-1"
          )
        when :mean_free_path
          v = Isa::NormalPrecision.instance.mean_free_path_of_air_particles_from_geopotential(gp_h_m)
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
