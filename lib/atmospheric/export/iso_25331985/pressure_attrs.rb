# frozen_string_literal: true

# The purpose of this class is to trim the attributes used in the ISO 2533:1985
# standard.
module Atmospheric
  module Export
    module Iso25331985
      class PressureAttrs < ::Atmospheric::Export::PressureAttrs
        key_value do
          map "pressure", to: :pressures
          map "geopotential-altitude", to: :geopotential_altitudes
        end
      end
    end
  end
end
