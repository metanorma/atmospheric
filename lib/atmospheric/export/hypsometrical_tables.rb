require_relative "./target"

module Atmospheric
  module Export

    module HypsometricalTables
      class TableBase
        include Target

        def to_h(unit: steps_unit)
          d = { "rows" => [] }
          steps.each do |p|
            d["rows"] << row(p, unit: unit)
          end
          d
        end

        def steps
          (0..0)
        end

        def steps_unit
          :mbar
        end

        def row(p, unit: steps_unit)
          {}
        end
      end

    end

  end
end
