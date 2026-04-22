# frozen_string_literal: true

module Atmospheric
  module Export
    module Iso25331985
      class TableFiveSixAttrs < ::Atmospheric::Export::Iso25331975::GroupOneAttrs
        # TODO: Completely override other attributes / key value mappings so
        # they don't show in YAML
        key_value do
          map "geopotential-altitude", to: :geopotential_altitudes
          map "pressure", to: :pressures
        end
      end
    end
  end
end
