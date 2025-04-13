require_relative "../pressure_attrs"

# The purpose of this class is to trim the attributes used in the ISO 2533:1985
# standard.
module Atmospheric
  module Export
    module Iso25331985
      class PressureAttrs < ::Atmospheric::Export::PressureAttrs
        key_value do
          map "pressure-mbar", to: :pressure_mbar
          map "pressure-mmhg", to: :pressure_mmhg
          map "geopotential-altitude-m", to: :geopotential_altitude_m
        end
      end
    end
  end
end
