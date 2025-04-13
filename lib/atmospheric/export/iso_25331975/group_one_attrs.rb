require "lutaml/model"
require_relative "../altitude_convertable_model"

module Atmospheric
  module Export
    module Iso25331975
      class GroupOneAttrs < Lutaml::Model::Serializable
        include AltitudeConvertableModel

        attribute :temperature_k, UnitValueInteger
        attribute :temperature_c, UnitValueInteger
        attribute :pressure_mbar, UnitValueFloat
        attribute :pressure_mmhg, UnitValueFloat
        attribute :density, UnitValueFloat
        attribute :acceleration, UnitValueFloat

        key_value do
          map "geometric-altitude-m", to: :geometric_altitude_m
          map "geometric-altitude-ft", to: :geometric_altitude_ft
          map "geopotential-altitude-m", to: :geopotential_altitude_m
          map "geopotential-altitude-ft", to: :geopotential_altitude_ft
          map "temperature-k", to: :temperature_k
          map "temperature-c", to: :temperature_c
          map "pressure-mbar", to: :pressure_mbar
          map "pressure-mmhg", to: :pressure_mmhg
          map "density", to: :density
          map "acceleration", to: :acceleration
        end

        # In meters only
        def realize_values_from_geopotential(gp_h_m, precision: :reduced)
          %i[
            temperature_k temperature_c pressure_mbar pressure_mmhg density
            acceleration
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
              unitsml: "K",
            )
          when :temperature_c
            v = Isa::NormalPrecision.instance.temperature_at_layer_celcius(gp_h_m)
            UnitValueInteger.new(
              value: precision == :reduced ? (v * 1000.0).round : v,
              unitsml: "degC",
            )
          when :pressure_mbar
            v = Isa::NormalPrecision.instance.pressure_from_geopotential_mbar(gp_h_m)
            UnitValueFloat.new(
              value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
              unitsml: "mbar",
            )
          when :pressure_mmhg
            v = Isa::NormalPrecision.instance.pressure_from_geopotential_mmhg(gp_h_m)
            UnitValueFloat.new(
              value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
              unitsml: "u:mm_Hg",
            )
          when :density
            v = Isa::NormalPrecision.instance.density_from_geopotential(gp_h_m)
            UnitValueFloat.new(
              value: precision == :reduced ? round_to_sig_figs(v, 6) : v,
              unitsml: "kg*m^-3",
            )
          when :acceleration
            v = Isa::NormalPrecision.instance.gravity_at_geopotential(gp_h_m)
            UnitValueFloat.new(
              value: precision == :reduced ? v.round(4) : v,
              unitsml: "m*s^-2",
            )
          else
            raise ArgumentError, "Unknown attribute: #{name}"
          end
        end
      end
    end
  end
end
