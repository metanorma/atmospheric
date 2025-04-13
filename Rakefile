# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

require "atmospheric"

task generate: [
  "generate_1975",
  "generate_1985",
  "generate_1997",
  "generate_2025",
]

task :clean do
  FileUtils.rm_rf "spec/fixtures/iso-2533-1975-new/yaml"
  FileUtils.rm_rf "spec/fixtures/iso-2533-add-1-1985-new/yaml"
  FileUtils.rm_rf "spec/fixtures/iso-2533-add-2-1997-new/yaml"
  FileUtils.rm_rf "spec/fixtures/iso-2533-2025/yaml"
end

directory "spec/fixtures/iso-2533-1975-new/yaml"

generate_1975_subtasks = [
  "spec/fixtures/iso-2533-1975-new/yaml",
]

(5..7).each do |n|
  filename = "spec/fixtures/iso-2533-1975-new/yaml/table#{n}.yaml"
  file filename do |t|
    File.write(t.name,
               Atmospheric::Export::Iso25331975.send("table_#{n}").to_yaml)
  end
  generate_1975_subtasks << filename
end

task generate_1975: generate_1975_subtasks

generate_1985_subtasks = [
  "spec/fixtures/iso-2533-add-1-1985-new/yaml",
]

directory "spec/fixtures/iso-2533-add-1-1985-new/yaml"

%w(1 2 3 4 56).each do |n|
  filename = "spec/fixtures/iso-2533-add-1-1985-new/yaml/table#{n}.yaml"
  file filename do |t|
    File.write(t.name,
               Atmospheric::Export::Iso25331985.send("table_#{n}").to_yaml)
  end
  generate_1985_subtasks << filename
end

task generate_1985: generate_1985_subtasks

generate_1997_subtasks = [
  "spec/fixtures/iso-2533-add-2-1997-new/yaml",
]

directory "spec/fixtures/iso-2533-add-2-1997-new/yaml"

(1..6).each do |n|
  filename = "spec/fixtures/iso-2533-add-2-1997-new/yaml/table#{n}.yaml"
  file filename do |t|
    File.write(t.name,
               Atmospheric::Export::Iso25331997.send("table_#{n}").to_yaml)
  end
  generate_1997_subtasks << filename
end

task generate_1997: generate_1997_subtasks

generate_2025_subtasks = [
  "spec/fixtures/iso-2533-2025/yaml",
]

directory "spec/fixtures/iso-2533-2025/yaml"

%w[
  table_atmosphere_meters
  table_atmosphere_feet
  table_hypsometrical_altitude
  table_hypsometrical_mbar
].each do |name|
  filename = "spec/fixtures/iso-2533-2025/yaml/#{name}.yaml"
  file filename do |t|
    File.write(t.name,
               Atmospheric::Export::Iso25332025.send(name.to_sym).to_yaml)
  end
  generate_2025_subtasks << filename
end

task generate_2025: generate_2025_subtasks
