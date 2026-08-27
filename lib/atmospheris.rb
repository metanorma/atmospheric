# frozen_string_literal: true

require "lutaml/model"

module Atmospheris
  class Error < StandardError; end

  autoload :VERSION, "atmospheris/version"
  autoload :Isa, "atmospheris/isa"
  autoload :Iso2533Namespace, "atmospheris/namespace"
  autoload :UnitValueFloat, "atmospheris/unit_value_float"
  autoload :UnitValueInteger, "atmospheris/unit_value_integer"
  autoload :Export, "atmospheris/export"
  autoload :Iso5878, "atmospheris/iso5878"
end
