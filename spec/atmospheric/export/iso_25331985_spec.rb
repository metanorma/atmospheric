# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/atmospheric/export/iso_25331985"

RSpec.describe Atmospheric::Export::Iso25331985 do
  table_mappings = [
    ["Table 1", "spec/fixtures/iso-2533-add-1-1985-new/yaml/table1.yaml",
     Atmospheric::Export::Iso25331985::TableOne],
    ["Table 2", "spec/fixtures/iso-2533-add-1-1985-new/yaml/table2.yaml",
     Atmospheric::Export::Iso25331985::TableTwo],
    ["Table 3", "spec/fixtures/iso-2533-add-1-1985-new/yaml/table3.yaml",
     Atmospheric::Export::Iso25331985::TableThree],
    ["Table 4", "spec/fixtures/iso-2533-add-1-1985-new/yaml/table4.yaml",
     Atmospheric::Export::Iso25331985::TableFour],
    ["Table 56", "spec/fixtures/iso-2533-add-1-1985-new/yaml/table56.yaml",
     Atmospheric::Export::Iso25331985::TableFiveSix]
  ]

  table_mappings.each do |table_name, yaml_path, parser|
    context table_name do
      it_behaves_like "yaml parsing and serialization", yaml_path, parser
    end
  end
end
