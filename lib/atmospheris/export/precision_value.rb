# frozen_string_literal: true

module Atmospheris
  class PrecisionValue < Lutaml::Model::Type::String
    xml do
      namespace Atmospheris::Iso2533Namespace
    end
  end
end
