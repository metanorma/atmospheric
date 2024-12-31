require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25332024"

RSpec.describe "Iso25332024 Parsing and Serialization" do
  let(:table_5_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table5.yaml"
  end
  let(:table_6_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table6.yaml"
  end
  let(:table_7_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table7.yaml"
  end
  let(:table_8_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table8.yaml"
  end
  let(:table_9_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table9.yaml"
  end
  let(:table_10_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table10.yaml"
  end
  let(:table_11_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table11.yaml"
  end
  let(:table_12_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table12.yaml"
  end
  let(:table_13_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-2024/yaml/table13.yaml"
  end

  it "correctly parses and serializes Table 5 YAML" do
    verify_yaml_round_trip(table_5_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupOneMeters)
  end

  it "correctly parses and serializes Table 6 YAML" do
    verify_yaml_round_trip(table_6_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupTwoMeters)
  end

  it "correctly parses and serializes Table 7 YAML" do
    verify_yaml_round_trip(table_7_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupThreeMeters)
  end

  it "correctly parses and serializes Table 8 YAML" do
    verify_yaml_round_trip(table_8_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupOneFeet)
  end

  it "correctly parses and serializes Table 9 YAML" do
    verify_yaml_round_trip(table_9_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupTwoFeet)
  end

  it "correctly parses and serializes Table 10 YAML" do
    verify_yaml_round_trip(table_10_yaml_path,
                           Atmospheric::Export::Iso25332024::GroupThreeFeet)
  end

  it "correctly parses and serializes Table 11 YAML" do
    verify_yaml_round_trip(table_11_yaml_path,
                           Atmospheric::Export::Iso25332024::HypsometricalMbar)
  end

  it "correctly parses and serializes Table 12 YAML" do
    verify_yaml_round_trip(table_12_yaml_path,
                           Atmospheric::Export::Iso25332024::HypsometricalGeometric)
  end

  it "correctly parses and serializes Table 13 YAML" do
    verify_yaml_round_trip(table_13_yaml_path,
                           Atmospheric::Export::Iso25332024::HypsometricalGeopotential)
  end
end
