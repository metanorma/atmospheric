require_relative "./target"
require_relative "./hypsometrical_tables"

module Atmospheric
  module Export

    module Iso25331985

      class TableOne < HypsometricalTables::TableBase
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
          (5.0..19.99).step(0.01).to_a.map {|v| v.round(2)}
        end

        def steps_unit
          :mbar
        end

        def row(p, unit: steps_unit)
          method_name = "geopotential_altitude_from_pressure_#{unit}"
          value = Isa.send(method_name, p).round
          {
            "pressure-#{unit}" => p,
            "geopotential-altitude" => value,
          }
        end
      end

      class TableTwo < HypsometricalTables::TableBase
        def steps
          (20.0..1199.9).step(0.1).to_a.map {|v| v.round(1)}
        end

        def row(p, unit:)
          method_name = "geopotential_altitude_from_pressure_#{unit}"
          value = Isa.send(method_name, p).round
          {
            "pressure-#{unit}" => p,
            "geopotential-altitude" => value,
          }
        end
      end

      # Same as Table 1 with mmHg
      class TableThree < TableOne
        def steps
          (4.0..9.99).step(0.01).to_a.map {|v| v.round(2)}
        end

        def steps_unit
          :mmhg
        end
      end

      # Same as Table 3 with mmHg
      class TableFour < TableTwo
        def steps
          (10.0..899.9).step(0.1).to_a.map {|v| v.round(1)}
        end

        def steps_unit
          :mmhg
        end
      end

      class TableFiveSix < HypsometricalTables::TableBase
        def steps
          (-1000..4599).step(1)
        end

        def row(h, unit:)
          {
            "geopotential-altitude" => h,
            "pressure-mbar" => round_to_sig_figs(Isa.pressure_from_geopotential_mbar(h.to_f), 6),
            "pressure-mmhg" => round_to_sig_figs(Isa.pressure_from_geopotential_mmhg(h.to_f), 6),
          }
        end
      end

      class << self

        def table_1
          TableOne.new.to_h
        end

        def table_1_yaml
          TableOne.new.to_yaml
        end

        def table_2
          TableTwo.new.to_h
        end

        def table_2_yaml
          TableTwo.new.to_yaml
        end

        def table_3
          TableThree.new.to_h
        end

        def table_3_yaml
          TableThree.new.to_yaml
        end

        def table_4
          TableFour.new.to_h
        end

        def table_4_yaml
          TableFour.new.to_yaml
        end

        def table_56
          TableFiveSix.new.to_h
        end

        def table_56_yaml
          TableFiveSix.new.to_yaml
        end

      end

    end

  end
end