require_relative "../altitude_table"
require_relative "../altitude_attrs"
require_relative "altitude_attrs_group"

module Atmospheric
  module Export
    module Iso25332025
      class CombinedAltitudeAttrsGroup < AltitudeTable
        attribute :by_geometric_altitude, AltitudeAttrsGroup
        attribute :by_geopotential_altitude, AltitudeAttrsGroup

        key_value do
          map "by-geometric-altitude", to: :by_geometric_altitude
          map "by-geopotential-altitude", to: :by_geopotential_altitude
        end

        xml do
          root "atmospheric"
          map_element "by-geometric-altitude", to: :by_geometric_altitude
          map_element "by-geopotential-altitude", to: :by_geopotential_altitude
        end

        def add_to_geometric(item)
          by_geometric_altitude.rows << item
        end

        def add_to_geopotential(item)
          by_geopotential_altitude.rows << item
        end

        def initialize_attrs
          self.by_geometric_altitude = AltitudeAttrsGroup.new(rows: [])
          self.by_geopotential_altitude = AltitudeAttrsGroup.new(rows: [])
        end

        def set_attrs(klass: AltitudeAttrs, unit: steps_unit)
          super
        end
      end
    end
  end
end
