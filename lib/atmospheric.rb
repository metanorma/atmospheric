# frozen_string_literal: true

require_relative "atmospheric/version"
require_relative "atmospheric/isa"
require_relative "atmospheric/export"
require 'lutaml/model'
require 'lutaml/model/xml_adapter/nokogiri_adapter'
require 'lutaml/model/json_adapter/standard_json_adapter'
require 'lutaml/model/yaml_adapter/standard_yaml_adapter'

Lutaml::Model::Config.configure do |config|
  config.xml_adapter = Lutaml::Model::XmlAdapter::NokogiriAdapter
  config.yaml_adapter = Lutaml::Model::YamlAdapter::StandardYamlAdapter
  config.json_adapter = Lutaml::Model::JsonAdapter::StandardJsonAdapter
end
module Atmospheric
  class Error < StandardError; end
  # Your code goes here...
end
