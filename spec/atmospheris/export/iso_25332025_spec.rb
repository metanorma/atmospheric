# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/atmospheris/export/iso_25332025"

RSpec.describe Atmospheris::Export::Iso25332025 do
  table_mappings = [
    ["AltitudesInMeters", "spec/fixtures/iso-2533-2025/yaml/table_atmosphere_meters.yaml",
     Atmospheris::Export::Iso25332025::AltitudesInMeters],
    ["AltitudesInFeet", "spec/fixtures/iso-2533-2025/yaml/table_atmosphere_feet.yaml",
     Atmospheris::Export::Iso25332025::AltitudesInFeet],
    ["AltitudesForPressure", "spec/fixtures/iso-2533-2025/yaml/table_hypsometrical_altitude.yaml",
     Atmospheris::Export::Iso25332025::AltitudesForPressure],
    ["HypsometricalMbar", "spec/fixtures/iso-2533-2025/yaml/table_hypsometrical_mbar.yaml",
     Atmospheris::Export::Iso25332025::HypsometricalMbar]
  ]

  table_mappings.each do |table_name, yaml_path, parser|
    context table_name do
      it_behaves_like "yaml parsing and serialization", yaml_path, parser
    end
  end
end
