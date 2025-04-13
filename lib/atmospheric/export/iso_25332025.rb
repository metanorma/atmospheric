require_relative "iso_25331975"
require_relative "iso_25332025/combined_altitude_attrs_group"

module Atmospheric
  module Export
    module Iso25332025
      class AltitudesInMeters < CombinedAltitudeAttrsGroup
        def steps
          (
            (-5000..31950).step(50) +
            (32000..50900).step(100) +
            (51000..80000).step(200)
          )
        end
      end

      class AltitudesInFeet < CombinedAltitudeAttrsGroup
        def steps
          (
            (-16500..-13750).step(250) +
            (-14000..104800).step(200) +
            (105000..262500).step(500)
          )
        end

        def steps_unit
          :feet
        end
      end

      class AltitudesForPressure < CombinedAltitudeAttrsGroup
        def steps
          (-1000..4599).step(1)
        end
      end

      class HypsometricalMbar < HypsometricalTable
        # TODO: when Ruby's step does not create inaccurate floating point numbers
        # This is a hack to solve a Ruby bug with floating point calcuations
        # > (20.0..1770.9).step(0.1).to_a
        #  ...
        #  1769.4,
        #  1769.5,
        #  1769.6000000000001, # <== we need to clean these
        #  1769.7,
        #  1769.8000000000002, # <== we need to clean these
        # The last `map` should be removed if this bug is fixed
        def steps
          (
            (5.0..19.99).step(0.01).to_a.map { |v| v.round(2) } +
            (20.0..1770.9).step(0.1).to_a.map { |v| v.round(1) }
          )
        end

        def steps_unit
          :mbar
        end
      end

      class << self
        def table_atmosphere_meters
          AltitudesInMeters.new.set_attrs
        end

        def table_atmosphere_feet
          AltitudesInFeet.new.set_attrs
        end

        def table_hypsometrical_altitude
          AltitudesForPressure.new.set_attrs
        end

        def table_hypsometrical_mbar
          HypsometricalMbar.new.set_attrs
        end
      end
    end
  end
end
