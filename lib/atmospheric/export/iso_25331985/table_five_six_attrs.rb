# frozen_string_literal: true

require_relative "../iso_25331975/group_one_attrs"

module Atmospheric
  module Export
    module Iso25331985
      class TableFiveSixAttrs < ::Atmospheric::Export::Iso25331975::GroupOneAttrs
        # TODO: Completely override other attributes / key value mappings so
        # they don't show in YAML
        key_value do
          map "geopotential-altitude-m", to: :geopotential_altitude_m
          map "pressure-mbar", to: :pressure_mbar
          map "pressure-mmhg", to: :pressure_mmhg
        end
      end
    end
  end
end
