# frozen_string_literal: true

module Atmospheris
  module Export
    class PressureAttrs < Lutaml::Model::Serializable
      include Utils
      attribute :pressures, UnitValueFloat, collection: true
      attribute :geometric_altitudes, UnitValueFloat, collection: true
      attribute :geopotential_altitudes, UnitValueFloat, collection: true

      key_value do
        map "pressure", to: :pressures
        map "geopotential-altitude", to: :geopotential_altitudes
        map "geometric-altitude", to: :geometric_altitudes
      end

      xml do
        element "hypsometrical-attributes"
        namespace Atmospheris::Iso2533Namespace
        map_element "pressure", to: :pressures
        map_element "geometric-altitude", to: :geometric_altitudes
        map_element "geopotential-altitude", to: :geopotential_altitudes
      end

      def set_pressure(value:, unit: :mbar, precision: :reduced)
        method_name = "geopotential_altitude_from_pressure_#{unit}"
        gp_h_m = Isa::NormalPrecision.instance.send(method_name, value)
        gp_h_ft = m_to_ft(gp_h_m)
        gm_h_m = Isa::NormalPrecision.instance.geometric_altitude_from_geopotential(gp_h_m)
        gm_h_ft = m_to_ft(gm_h_m)

        realize_altitudes(gm_h_m, gm_h_ft, gp_h_m, gp_h_ft, precision: precision)
        realize_pressures(value, unit: unit)

        self
      end

      def realize_altitudes(hgmm, hgmf, hgpm, hgpf, precision: :reduced)
        self.geometric_altitudes = [
          UnitValueFloat.new(
            value: precision == :reduced ? hgmm.round(1) : hgmm,
            unitsml: "m"
          ),
          UnitValueFloat.new(
            value: precision == :reduced ? hgmf.round : hgmf,
            unitsml: "ft"
          )
        ]

        self.geopotential_altitudes = [
          UnitValueFloat.new(
            value: precision == :reduced ? hgpm.round(1) : hgpm,
            unitsml: "m"
          ),
          UnitValueFloat.new(
            value: precision == :reduced ? hgpf.round : hgpf,
            unitsml: "ft"
          )
        ]
      end

      def realize_pressures(input, unit:)
        self.pressures = case unit
                         when :mbar
                           [
                             UnitValueFloat.new(value: input, unitsml: "mbar"),
                             UnitValueFloat.new(
                               value: Isa::NormalPrecision.instance.mbar_to_mmhg(input),
                               unitsml: "mm_Hg"
                             )
                           ]
                         when :mmhg
                           [
                             UnitValueFloat.new(
                               value: Isa::NormalPrecision.instance.mmhg_to_mbar(input),
                               unitsml: "mbar"
                             ),
                             UnitValueFloat.new(value: input, unitsml: "mm_Hg")
                           ]
                         else
                           raise ArgumentError,
                                 "Invalid unit: #{unit}. Use :mbar or :mmhg."
                         end
      end
    end
  end
end
