require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25331975"

RSpec.describe "Iso25331975 Parsing and Serialization" do
  let(:table_5_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table5.yaml"
  end
  let(:table_6_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table6.yaml"
  end
  let(:table_7_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table7.yaml"
  end

  it "correctly parses and serializes Table 5 YAML" do
    verify_yaml_round_trip(table_5_yaml_path,
                           Atmospheric::Export::Iso25331975::GroupOne)
  end

  it "correctly parses and serializes Table 6 YAML" do
    verify_yaml_round_trip(table_6_yaml_path,
                           Atmospheric::Export::Iso25331975::GroupTwo)
  end

  it "correctly parses and serializes Table 7 YAML" do
    verify_yaml_round_trip(table_7_yaml_path,
                           Atmospheric::Export::Iso25331975::GroupThree)
  end
end
