require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25331997"

RSpec.describe "Iso25331997 Parsing and Serialization" do
  let(:table_1_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table1.yaml"
  end
  let(:table_2_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table2.yaml"
  end
  let(:table_3_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table3.yaml"
  end
  let(:table_4_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table4.yaml"
  end
  let(:table_5_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table5.yaml"
  end
  let(:table_6_yaml_path) do
    "spec/fixtures/iso2533/sources/iso-2533-add-2-1997-new/yaml/table6.yaml"
  end

  it "correctly parses and serializes Table 1 YAML" do
    verify_yaml_round_trip(table_1_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupOne)
  end

  it "correctly parses and serializes Table 2 YAML" do
    verify_yaml_round_trip(table_2_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupTwo)
  end

  it "correctly parses and serializes Table 3 YAML" do
    verify_yaml_round_trip(table_3_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupThree)
  end

  it "correctly parses and serializes Table 4 YAML" do
    verify_yaml_round_trip(table_4_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupFour)
  end

  it "correctly parses and serializes Table 5 YAML" do
    verify_yaml_round_trip(table_5_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupFive)
  end

  it "correctly parses and serializes Table 6 YAML" do
    verify_yaml_round_trip(table_6_yaml_path,
                           Atmospheric::Export::Iso25331997::GroupSix)
  end
end
