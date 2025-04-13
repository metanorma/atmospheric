# frozen_string_literal: true

require "lutaml/model"

module Atmospheric
  module Export
    module Iso25331975
      class GroupThreeAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

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
          map "pressure-scale-height", to: :pressure_scale_height
          map "specific-weight", to: :specific_weight
          map "air-number-density", to: :air_number_density
          map "mean-speed", to: :mean_speed
          map "frequency", to: :frequency
          map "mean-free-path", to: :mean_free_path
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
          %i[
            pressure_scale_height specific_weight air_number_density mean_speed
            frequency mean_free_path
          ].each do |attr|
            v = calculate(gp_h_m, attr, precision: precision)
            send("#{attr}=", v) if respond_to?("#{attr}=")
          end
        end

        def calculate(gp_h_m, name, precision: :reduced)
          case name
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
end
