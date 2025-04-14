# frozen_string_literal: true

require "lutaml/model"
require_relative "utils"
require_relative "../unit_value_float"
require_relative "../unit_value_integer"

module Atmospheric
  module Export
    class PressureAttrs < Lutaml::Model::Serializable
      include Utils
      attribute :pressure_mbar, UnitValueFloat
      attribute :pressure_mmhg, UnitValueFloat
      attribute :geometric_altitude_m, UnitValueFloat
      attribute :geometric_altitude_ft, UnitValueInteger
      attribute :geopotential_altitude_m, UnitValueFloat
      attribute :geopotential_altitude_ft, UnitValueInteger

      key_value do
        map "pressure-mbar", to: :pressure_mbar
        map "pressure-mmhg", to: :pressure_mmhg
        map "geopotential-altitude-m", to: :geopotential_altitude_m
        map "geopotential-altitude-ft", to: :geopotential_altitude_ft
        map "geometric-altitude-m", to: :geometric_altitude_m
        map "geometric-altitude-ft", to: :geometric_altitude_ft
      end

      xml do
        root "hypsometrical-attributes"
        map_element "pressure-mbar", to: :pressure_mbar
        map_element "pressure-mmhg", to: :pressure_mmhg
        map_element "geometric-altitude-m", to: :geometric_altitude_m
        map_element "geometric-altitude-ft", to: :geometric_altitude_ft
        map_element "geopotential-altitude-m", to: :geopotential_altitude_m
        map_element "geopotential-altitude-ft", to: :geopotential_altitude_ft
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

      # TODO: Not sure why we need round(1) for meter values
      def realize_altitudes(hgmm, hgmf, hgpm, hgpf, precision: :reduced)
        self.geometric_altitude_m = UnitValueFloat.new(
          value: precision == :reduced ? hgmm.round(1) : hgmm,
          unitsml: "m"
        )

        self.geometric_altitude_ft = UnitValueInteger.new(
          value: precision == :reduced ? hgmf.round : hgmf,
          unitsml: "ft"
        )

        self.geopotential_altitude_m = UnitValueFloat.new(
          value: precision == :reduced ? hgpm.round(1) : hgpm,
          unitsml: "m"
        )

        self.geopotential_altitude_ft = UnitValueInteger.new(
          value: precision == :reduced ? hgpf.round : hgpf,
          unitsml: "ft"
        )
      end

      def realize_pressures(input, unit:)
        # pattern: [value in mbar, value in mmhg]
        mbar, mmhg = case unit
                     when :mbar
                       [input,
                        Isa::NormalPrecision.instance.mbar_to_mmhg(input)]
                     when :mmhg
                       [Isa::NormalPrecision.instance.mmhg_to_mbar(input),
                        input]
                     else
                       raise ArgumentError,
                             "Invalid unit: #{unit}. Use :mbar or :mmhg."
                     end

        self.pressure_mbar = UnitValueFloat.new(value: mbar, unitsml: "mbar")
        self.pressure_mmhg = UnitValueFloat.new(value: mmhg, unitsml: "mmhg")
      end
    end
  end
end
