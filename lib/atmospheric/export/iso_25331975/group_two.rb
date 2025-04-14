# frozen_string_literal: true

require_relative "../altitude_table"
require_relative "group_two_attrs"

module Atmospheric
  module Export
    module Iso25331975
      class GroupTwo < AltitudeTable
        attribute :by_geometric_altitude, GroupTwoAttrs, collection: true
        attribute :by_geopotential_altitude, GroupTwoAttrs, collection: true

        key_value do
          map "by-geometric-altitude", to: :by_geometric_altitude
          map "by-geopotential-altitude", to: :by_geopotential_altitude
        end

        def set_attrs(klass: GroupTwoAttrs, unit: steps_unit, precision: :reduced)
          super
        end
      end
    end
  end
end
