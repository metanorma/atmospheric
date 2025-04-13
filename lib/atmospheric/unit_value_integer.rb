require "lutaml/model"

module Atmospheric
  class UnitValueInteger < Lutaml::Model::Serializable
    attribute :value, :integer
    attribute :unitsml, :string
    attribute :type, :string, default: -> { "integer" }

    key_value do
      map "value", to: :value
      map "unitsml", to: :unitsml
      map "type", to: :type, render_default: true
    end

    xml do
      root "unit-value-integer"
      map_content to: :value
      map_attribute :unitsml, to: :unitsml
      map_attribute :type, to: :type, render_default: true
    end
  end
end
