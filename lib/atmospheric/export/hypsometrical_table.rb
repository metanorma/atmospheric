# frozen_string_literal: true

require "lutaml/model"
require_relative "pressure_attrs"

module Atmospheric
  module Export
    class HypsometricalTable < Lutaml::Model::Serializable
      attribute :rows, PressureAttrs, collection: true

      xml do
        root "atmospheric"
        map_element "hypsometrical-attributes", to: :rows
      end

      def steps
        (0..0)
      end

      def steps_unit
        :mbar
      end

      def initialize_attrs
        self.rows = []
      end

      def set_attrs(klass: PressureAttrs, unit: steps_unit)
        initialize_attrs

        steps.each do |p|
          rows << klass.new.set_pressure(value: p, unit: unit)
        end
        self
      end
    end
  end
end
