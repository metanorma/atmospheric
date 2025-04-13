require "lutaml/model"

module Atmospheric
  module Export
    class AltitudeTable < Lutaml::Model::Serializable
      # Step 50 from -2k to 40k, step 100 above 32k, 200 above 51k to 80k
      def steps
        ((-2000..31950).step(50) +
         (32000..50900).step(100) +
         (51000..80000).step(200))
      end

      def steps_unit
        :meters
      end

      def add_to_geometric(item)
        by_geometric_altitude << item
      end

      def add_to_geopotential(item)
        by_geopotential_altitude << item
      end

      def initialize_attrs
        self.by_geometric_altitude = []
        self.by_geopotential_altitude = []
      end

      def set_attrs(klass:, unit: steps_unit)
        initialize_attrs

        steps.each do |h|
          add_to_geometric(
            klass.new.set_altitude(
              type: :geometric, unit: unit, value: h,
            ),
          )
          add_to_geopotential(
            klass.new.set_altitude(
              type: :geopotential, unit: unit, value: h,
            ),
          )
        end
        self
      end
    end
  end
end
