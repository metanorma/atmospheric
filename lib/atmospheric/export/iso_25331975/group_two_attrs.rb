# frozen_string_literal: true

require "lutaml/model"

module Atmospheric
  module Export
    module Iso25331975
      class GroupTwoAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

        attribute :ppns, UnitValueFloat, collection: true
        attribute :rhorhons, UnitValueFloat, collection: true
        attribute :sqrt_rhorhons, UnitValueFloat, collection: true
        attribute :speeds_of_sound, UnitValueInteger, collection: true
        attribute :dynamic_viscosities, UnitValueFloat, collection: true
        attribute :kinematic_viscosities, UnitValueFloat, collection: true
        attribute :thermal_conductivities, UnitValueFloat, collection: true

        key_value do
          map "geometric-altitude", to: :geometric_altitudes
          map "geopotential-altitude", to: :geopotential_altitudes
          map "ppn", to: :ppns
          map "rhorhon", to: :rhorhons
          map "sqrt-rhorhon", to: :sqrt_rhorhons
          map "speed-of-sound", to: :speeds_of_sound
          map "dynamic-viscosity", to: :dynamic_viscosities
          map "kinematic-viscosity", to: :kinematic_viscosities
          map "thermal-conductivity", to: :thermal_conductivities
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
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
        end

        def calculate(gp_h_m, name, precision: :reduced)
          isa = precision == :high ? Isa::HighPrecision.instance : Isa::NormalPrecision.instance

          case name
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
            UnitValueInteger.new(
              value: precision == :reduced ? (v * 1000.0).round : v,
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
          else
            raise ArgumentError, "Unknown attribute: #{name}"
          end
        end
      end
    end
  end
end
