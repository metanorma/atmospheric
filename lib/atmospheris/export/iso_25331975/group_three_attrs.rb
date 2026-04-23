# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso25331975
      class GroupThreeAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

        attribute :pressure_scale_heights, UnitValueFloat, collection: true
        attribute :specific_weights, UnitValueFloat, collection: true
        attribute :air_number_densities, UnitValueFloat, collection: true
        attribute :mean_speeds, UnitValueFloat, collection: true
        attribute :frequencies, UnitValueFloat, collection: true
        attribute :mean_free_paths, UnitValueFloat, collection: true

        key_value do
          map "geometric-altitude", to: :geometric_altitudes
          map "geopotential-altitude", to: :geopotential_altitudes
          map "pressure-scale-height", to: :pressure_scale_heights
          map "specific-weight", to: :specific_weights
          map "air-number-density", to: :air_number_densities
          map "mean-speed", to: :mean_speeds
          map "frequency", to: :frequencies
          map "mean-free-path", to: :mean_free_paths
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
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
end
