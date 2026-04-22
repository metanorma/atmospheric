# frozen_string_literal: true

module Atmospheric
  class PrecisionValue < Lutaml::Model::Type::String
    xml do
      namespace Atmospheric::Iso2533Namespace
    end
  end
end
