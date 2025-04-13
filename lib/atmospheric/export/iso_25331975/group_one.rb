# frozen_string_literal: true

require_relative "../altitude_table"
require_relative "group_one_attrs"

module Atmospheric
  module Export
    module Iso25331975
      class GroupOne < AltitudeTable
        attribute :by_geometric_altitude, GroupOneAttrs, collection: true
        attribute :by_geopotential_altitude, GroupOneAttrs, collection: true

        key_value do
          map "by-geometric-altitude", to: :by_geometric_altitude
          map "by-geopotential-altitude", to: :by_geopotential_altitude
        end

        def set_attrs(klass: GroupOneAttrs, unit: steps_unit)
          super
        end
      end
    end
  end
end
