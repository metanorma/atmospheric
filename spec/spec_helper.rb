# frozen_string_literal: true

require "atmospheric"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def verify_yaml_round_trip(yaml_path, model_class)
  # Read the original YAML file
  original_yaml = File.read(yaml_path)

  # Parse the YAML content using the model's from_yaml method
  model_instance = model_class.from_yaml(original_yaml)

  # Convert the object back to YAML
  generated_yaml = model_instance.to_yaml

  # Ensure the generated YAML matches the original YAML
  expect(YAML.load(generated_yaml.strip)).to eq(YAML.load(original_yaml.strip))
end
