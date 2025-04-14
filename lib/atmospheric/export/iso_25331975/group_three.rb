# frozen_string_literal: true

require_relative "../altitude_table"
require_relative "group_three_attrs"

module Atmospheric
  module Export
    module Iso25331975
      class GroupThree < AltitudeTable
        attribute :by_geometric_altitude, GroupThreeAttrs, collection: true
        attribute :by_geopotential_altitude, GroupThreeAttrs, collection: true

        key_value do
          map "by-geometric-altitude", to: :by_geometric_altitude
          map "by-geopotential-altitude", to: :by_geopotential_altitude
        end

        def set_attrs(klass: GroupThreeAttrs, unit: steps_unit, precision: :reduced)
          super
        end
      end
    end
  end
end
