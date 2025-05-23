# frozen_string_literal: true

require_relative "utils"
require_relative "../unit_value_float"
require_relative "../unit_value_integer"

module Atmospheric
  module Export
    module AltitudeConvertableModel
      include Utils

      def self.included(base)
        base.class_eval do
          attribute :geometric_altitude_m, UnitValueInteger
          attribute :geometric_altitude_ft, UnitValueInteger
          attribute :geopotential_altitude_m, UnitValueInteger
          attribute :geopotential_altitude_ft, UnitValueInteger
        end
      end

      def set_altitude(value:, type: :geometric, unit: :meters,
                       precision: :reduced)
        case type
        when :geometric
          set_geometric_altitude(value, unit: unit, precision: precision)
        when :geopotential
          set_geopotential_altitude(value, unit: unit, precision: precision)
        else
          raise ArgumentError,
                "Invalid type: #{type}. Use :geometric or :geopotential."
        end

        self
      end

      def set_geopotential_altitude(h, unit: :meters, precision: :reduced)
        hgpm, hgpf = values_in_m_ft(h, unit: unit)
        hgmm = Isa::NormalPrecision.instance.geometric_altitude_from_geopotential(hgpm)
        hgmf = m_to_ft(hgmm).round
        # TODO: We have to used reduced here because we must round values for
        # the Integer data type as defined.
        realize_altitudes(hgmm, hgmf, hgpm, hgpf, precision: :reduced)
        realize_values_from_geopotential(hgpm, precision: precision)
      end

      def set_geometric_altitude(h, unit: :meters, precision: :reduced)
        hgmm, hgmf = values_in_m_ft(h, unit: unit)
        hgpm = Isa::NormalPrecision.instance.geopotential_altitude_from_geometric(hgmm)
        hgpf = m_to_ft(hgpm).round
        # TODO: We have to used reduced here because we must round values for
        # the Integer data type as defined.
        realize_altitudes(hgmm, hgmf, hgpm, hgpf, precision: :reduced)
        realize_values_from_geopotential(hgpm, precision: precision)
      end

      def realize_altitudes(hgmm, hgmf, hgpm, hgpf, precision: :reduced)
        self.geometric_altitude_m = UnitValueInteger.new(
          value: precision == :reduced ? hgmm.round : hgmm,
          unitsml: "m"
        )

        self.geometric_altitude_ft = UnitValueInteger.new(
          value: precision == :reduced ? hgmf.round : hgmf,
          unitsml: "ft"
        )

        self.geopotential_altitude_m = UnitValueInteger.new(
          value: precision == :reduced ? hgpm.round : hgpm,
          unitsml: "m"
        )

        self.geopotential_altitude_ft = UnitValueInteger.new(
          value: precision == :reduced ? hgpf.round : hgpf,
          unitsml: "ft"
        )
      end

      def realize_values_from_geopotential(gp_h_m, precision:)
        raise NotImplementedError,
              "realize_values_from_geopotential method must be implemented in the including class"
      end
    end
  end
end
