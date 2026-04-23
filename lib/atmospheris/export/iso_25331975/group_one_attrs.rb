# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso25331975
      class GroupOneAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

        attribute :temperatures, UnitValueInteger, collection: true
        attribute :pressures, UnitValueFloat, collection: true
        attribute :densities, UnitValueFloat, collection: true
        attribute :accelerations, UnitValueFloat, collection: true

        key_value do
          map "geometric-altitude", to: :geometric_altitudes
          map "geopotential-altitude", to: :geopotential_altitudes
          map "temperature", to: :temperatures
          map "pressure", to: :pressures
          map "density", to: :densities
          map "acceleration", to: :accelerations
        end

        xml do
          element "group-one-attrs"
          map_element "geometric-altitude", to: :geometric_altitudes
          map_element "geopotential-altitude", to: :geopotential_altitudes
          map_element "temperature", to: :temperatures
          map_element "pressure", to: :pressures
          map_element "density", to: :densities
          map_element "acceleration", to: :accelerations
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
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
        end

        def calculate(gp_h_m, name, precision: :reduced)
          isa = precision == :high ? Isa::HighPrecision.instance : Isa::NormalPrecision.instance

          case name
          when :temperature_k
            v = isa.temperature_at_layer_from_geopotential(gp_h_m)
            UnitValueInteger.new(
              value: precision == :reduced ? (v * 1000.0).round : v,
              unitsml: "K"
            )
          when :temperature_c
            v = isa.temperature_at_layer_celcius(gp_h_m)
            UnitValueInteger.new(
              value: precision == :reduced ? (v * 1000.0).round : v,
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
          else
            raise ArgumentError, "Unknown attribute: #{name}"
          end
        end
      end
    end
  end
end
