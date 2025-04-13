require_relative "hypsometrical_table"
require_relative "iso_25331985/pressure_attrs"
require_relative "iso_25331985/table_five_six_attrs"
require_relative "iso_25332024/combined_altitude_attrs_group"

module Atmospheric
  module Export
    module Iso25331985
      class TableOne < HypsometricalTable
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

        attribute :rows, PressureAttrs, collection: true

        def steps
          (5.0..19.99).step(0.01).to_a.map { |v| v.round(2) }
        end

        def steps_unit
          :mbar
        end

        def set_attrs(klass: PressureAttrs, unit: steps_unit)
          super
        end
      end

      class TableTwo < HypsometricalTable
        attribute :rows, PressureAttrs, collection: true

        def steps
          (20.0..1199.9).step(0.1).to_a.map { |v| v.round(1) }
        end

        def set_attrs(klass: PressureAttrs, unit: steps_unit)
          super
        end
      end

      class TableThree < TableOne
        attribute :rows, PressureAttrs, collection: true

        def steps
          (4.0..9.99).step(0.01).to_a.map { |v| v.round(2) }
        end

        def steps_unit
          :mmhg
        end

        def set_attrs(klass: PressureAttrs, unit: steps_unit)
          super
        end
      end

      class TableFour < TableTwo
        attribute :rows, PressureAttrs, collection: true

        def steps
          (10.0..899.9).step(0.1).to_a.map { |v| v.round(1) }
        end

        def steps_unit
          :mmhg
        end

        def set_attrs(klass: PressureAttrs, unit: steps_unit)
          super
        end
      end

      class TableFiveSix < Iso25332024::CombinedAltitudeAttrsGroup
        def steps
          (-1000..4599).step(1)
        end

        def set_attrs(klass: TableFiveSixAttrs, unit: steps_unit)
          super
        end
      end

      class << self
        def table_1
          TableOne.new.set_attrs
        end

        def table_2
          TableTwo.new.set_attrs
        end

        def table_3
          TableThree.new.set_attrs
        end

        def table_4
          TableFour.new.set_attrs
        end

        def table_56
          TableFiveSix.new.set_attrs
        end
      end
    end
  end
end
