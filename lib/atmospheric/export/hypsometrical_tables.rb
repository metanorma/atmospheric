require_relative "./target"
require 'lutaml/model'

module Atmospheric
  module Export
    module HypsometricalTables
      class TableBase < Lutaml::Model::Serializable
        include Target

        def to_h(unit: steps_unit)
          { "rows" => steps.inject([]) { |rows, p| rows << row(p, unit: unit) } }
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

        def set_attrs(klass:, unit: steps_unit)
          self.rows = []
          steps.each do |p|
            self.rows << klass.from_json(row(p, unit: unit).to_json)
          end
          self
        end
      end
    end
  end
end
