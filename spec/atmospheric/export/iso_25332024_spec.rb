require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25332024"

RSpec.describe Atmospheric::Export::Iso25332024 do
  table_mappings = [
    ["AltitudesInMeters", "spec/fixtures/iso-2533-2024/yaml/table_atmosphere_meters.yaml",
     Atmospheric::Export::Iso25332024::AltitudesInMeters],
    ["AltitudesInFeet", "spec/fixtures/iso-2533-2024/yaml/table_atmosphere_feet.yaml",
     Atmospheric::Export::Iso25332024::AltitudesInFeet],
    ["AltitudesForPressure", "spec/fixtures/iso-2533-2024/yaml/table_hypsometrical_altitude.yaml",
     Atmospheric::Export::Iso25332024::AltitudesForPressure],
    ["HypsometricalMbar", "spec/fixtures/iso-2533-2024/yaml/table_hypsometrical_mbar.yaml",
     Atmospheric::Export::Iso25332024::HypsometricalMbar],
  ]

  table_mappings.each do |table_name, yaml_path, parser|
    context table_name do
      it_behaves_like "yaml parsing and serialization", yaml_path, parser
    end
  end
end
