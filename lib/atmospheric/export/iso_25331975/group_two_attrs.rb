# frozen_string_literal: true

require "lutaml/model"

module Atmospheric
  module Export
    module Iso25331975
      class GroupTwoAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

        attribute :ppn, UnitValueFloat
        attribute :rhorhon, UnitValueFloat
        attribute :sqrt_rhorhon, UnitValueFloat
        attribute :speed_of_sound, UnitValueInteger
        attribute :dynamic_viscosity, UnitValueFloat
        attribute :kinematic_viscosity, UnitValueFloat
        attribute :thermal_conductivity, UnitValueFloat

        key_value do
          map "geometric-altitude-m", to: :geometric_altitude_m
          map "geometric-altitude-ft", to: :geometric_altitude_ft
          map "geopotential-altitude-m", to: :geopotential_altitude_m
          map "geopotential-altitude-ft", to: :geopotential_altitude_ft
          map "ppn", to: :ppn
          map "rhorhon", to: :rhorhon
          map "sqrt-rhorhon", to: :sqrt_rhorhon
          map "speed-of-sound", to: :speed_of_sound
          map "dynamic-viscosity", to: :dynamic_viscosity
          map "kinematic-viscosity", to: :kinematic_viscosity
          map "thermal-conductivity", to: :thermal_conductivity
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
          %i[
            ppn rhorhon sqrt_rhorhon speed_of_sound
            dynamic_viscosity kinematic_viscosity thermal_conductivity
          ].each do |attr|
            v = calculate(gp_h_m, attr, precision: precision)
            send("#{attr}=", v) if respond_to?("#{attr}=")
          end
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
