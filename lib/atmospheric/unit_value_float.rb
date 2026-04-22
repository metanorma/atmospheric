# frozen_string_literal: true

module Atmospheric
  class UnitValueFloat < Lutaml::Model::Serializable
    attribute :value, :float
    attribute :unitsml, :string
    attribute :type, :string, default: -> { "float" }

    key_value do
      map "value", to: :value
      map "unitsml", to: :unitsml
      map "type", to: :type, render_default: true
    end

    xml do
      element "unit-value-float"
      namespace Atmospheric::Iso2533Namespace
      map_content to: :value
      map_attribute :unitsml, to: :unitsml
      map_attribute :type, to: :type, render_default: true
    end
  end
end
