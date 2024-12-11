require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25331975"

RSpec.describe "Iso25331975 Parsing and Serialization" do
  let(:table_5_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table5.yaml" }
  let(:table_6_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table6.yaml" }
  let(:table_7_yaml_path) { "spec/fixtures/iso2533/sources/iso-2533-1975-new/yaml/table7.yaml" }

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

  it 'correctly parses and serializes Table 5 YAML' do
    verify_yaml_round_trip(table_5_yaml_path, Atmospheric::Export::Iso25331975::GroupOne)
  end

  it 'correctly parses and serializes Table 6 YAML' do
    verify_yaml_round_trip(table_6_yaml_path, Atmospheric::Export::Iso25331975::GroupTwo)
  end

  it 'correctly parses and serializes Table 7 YAML' do
    verify_yaml_round_trip(table_7_yaml_path, Atmospheric::Export::Iso25331975::GroupThree)
  end
end
