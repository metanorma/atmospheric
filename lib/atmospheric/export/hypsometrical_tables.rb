require_relative "./target"

module Atmospheric
  module Export

    module HypsometricalTables
      class TableBase
        include Target

        def to_h
          d = { "rows" => [] }
          steps.each do |p|
            d["rows"] << row(p)
          end
          d
        end

        def steps
          (0..0)
        end

        def row(p)
          {}
        end
      end

      class TableOne < TableBase
        def steps
          (5.0..19.99).step(0.01)
        end

        def row(p)
          {
            "pressure-mbar" => p.round(2),
            "geopotential-altitude" => Isa.geopotential_altitude_from_pressure_mbar(p.round(2)).round,
          }
        end
      end

      class TableTwo < TableBase
        def steps
          (20.0..1199.9).step(0.1)
        end

        def row(p)
          {
            "pressure-mbar" => p.round(1),
            "geopotential-altitude" => Isa.geopotential_altitude_from_pressure_mbar(p.round(1)).round,
          }
        end
      end

      class TableThree < TableBase
        def steps
          (4.0..9.99).step(0.01)
        end

        def row(p)
          {
            "pressure-mmhg" => p.round(2),
            "geopotential-altitude" => Isa.geopotential_altitude_from_pressure_mmhg(p.round(2)).round,
          }
        end
      end

      class TableFour < TableBase
        def steps
          (10.0..899.9).step(0.1)
        end

        def row(p)
          {
            "pressure-mmhg" => p.round(1),
            "geopotential-altitude" => Isa.geopotential_altitude_from_pressure_mmhg(p.round(1)).round,
          }
        end
      end

      class TableFiveSix < TableBase
        def steps
          (-1000..4599).step(1)
        end

        def row(h)
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
