# frozen_string_literal: true

require "lutaml/model"

module Atmospheric
  class Error < StandardError; end

  autoload :VERSION, "atmospheric/version"
  autoload :Isa, "atmospheric/isa"
  autoload :Iso2533Namespace, "atmospheric/namespace"
  autoload :UnitValueFloat, "atmospheric/unit_value_float"
  autoload :UnitValueInteger, "atmospheric/unit_value_integer"
  autoload :Export, "atmospheric/export"
end
