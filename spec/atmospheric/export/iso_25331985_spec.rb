require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25331985"

RSpec.describe "Iso25331985 Parsing and Serialization" do
  let(:table_1_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-add-1-1985-new/yaml/table1.yaml" }
  let(:table_2_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-add-1-1985-new/yaml/table2.yaml" }
  let(:table_3_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-add-1-1985-new/yaml/table3.yaml" }
  let(:table_4_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-add-1-1985-new/yaml/table4.yaml" }
  let(:table_56_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-add-1-1985-new/yaml/table56.yaml" }

  def verify_yaml_round_trip(yaml_path, model_class)
    # Read the original YAML file
    original_yaml = File.read(yaml_path)

    # Parse the YAML content using the model's from_yaml method
    model_instance = model_class.from_yaml(original_yaml)

    # Convert the object back to YAML
    generated_yaml = model_instance.to_yaml

    # Ensure the generated YAML matches the original YAML
    expect(YAML.load(generated_yaml.strip)).to eq(YAML.load original_yaml.strip)
  end

  it 'correctly parses and serializes Table 1 YAML' do
    verify_yaml_round_trip(table_1_yaml_path, Atmospheric::Export::Iso25331985::TableOne)
  end

  it 'correctly parses and serializes Table 2 YAML' do
    verify_yaml_round_trip(table_2_yaml_path, Atmospheric::Export::Iso25331985::TableTwo)
  end

  it 'correctly parses and serializes Table 3 YAML' do
    verify_yaml_round_trip(table_3_yaml_path, Atmospheric::Export::Iso25331985::TableThree)
  end

  it 'correctly parses and serializes Table 4 YAML' do
    verify_yaml_round_trip(table_4_yaml_path, Atmospheric::Export::Iso25331985::TableFour)
  end

  it 'correctly parses and serializes Table 56 YAML' do
    verify_yaml_round_trip(table_56_yaml_path, Atmospheric::Export::Iso25331985::TableFiveSix)
  end
end