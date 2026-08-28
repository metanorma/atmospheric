# frozen_string_literal: true

require "spec_helper"
require "atmospheris/export/iso_5878"
require "yaml"

RSpec.describe Atmospheris::Export::Iso5878::AtmosphereProfileExport do
  let(:params) { Atmospheris::Iso5878::SurfaceParameters.new(15) }

  let(:layers) do
    Atmospheris::Iso5878::TemperatureLayerStructure.from_yaml_rows([
                                                                     { geopotential_altitude: 0.0,
                                                                       temperature_K: 299.65 },
                                                                     { geopotential_altitude: 2.250,
                                                                       temperature_K: 286.15 },
                                                                     { geopotential_altitude: 16.500,
                                                                       temperature_K: 193.15 },
                                                                     { geopotential_altitude: 30.000,
                                                                       temperature_K: 231.15 },
                                                                     { geopotential_altitude: 80.000,
                                                                       temperature_K: 198.15 }
                                                                   ]).to_a
  end

  let(:profile) do
    Atmospheris::Iso5878::AtmosphereProfile.new(
      surface_params: params,
      surface_temperature: 299.65,
      surface_pressure: 101_325.0,
      layers: layers
    )
  end

  let(:export) do
    described_class.new(
      profile,
      table_id: "test-table",
      title_en: "Test Table",
      geometric_altitudes: [0, 5000, 10_000, 20_000]
    )
  end

  describe "#generate" do
    subject(:data) { export.generate }

    it "returns a Hash with required keys" do
      expect(data).to be_a(Hash)
      expect(data.keys).to include("id", "title-en", "rows-h")
    end

    it "sets table metadata" do
      expect(data["id"]).to eq("test-table")
      expect(data["title-en"]).to eq("Test Table")
    end

    it "has one row per altitude" do
      expect(data["rows-h"].length).to eq(4)
    end

    it "computes correct surface row" do
      row = data["rows-h"][0]
      expect(row["geometrical-altitude"]).to eq(0)
      expect(row["temperature-K"]).to be_within(0.01).of(299.65)
      expect(row["p-mbar"]).to be_within(0.5).of(1013.25)
    end

    it "computes correct mid-altitude row" do
      row = data["rows-h"][1] # 5000m geometric
      expect(row["temperature-K"]).to be > 200
      expect(row["temperature-K"]).to be < 300
      expect(row["p-mbar"]).to be > 300
      expect(row["p-mbar"]).to be < 700
    end

    it "includes all required row fields" do
      row = data["rows-h"][0]
      expect(row.keys).to contain_exactly(
        "geometrical-altitude", "geopotential-altitude",
        "temperature-K", "temperature-C", "p-mbar", "density"
      )
    end

    it "temperature-C = temperature-K - 273.15" do
      data["rows-h"].each do |row|
        expected_c = row["temperature-K"] - 273.15
        expect(row["temperature-C"]).to be_within(0.01).of(expected_c)
      end
    end
  end

  describe "cross-validation against Table 3 YAML" do
    let(:yaml_base) do
      # Allow overriding for standard-source cross-checks, but default to vendored fixtures
      candidates = [
        ENV["ISO5878_YAML_ROOT"],
        File.expand_path("../../fixtures/iso-5878-2025/yaml", __dir__)
      ].compact
      candidates.find { |p| Dir.exist?(p) }
    end

    before do
      skip "YAML data not found at #{yaml_base}" unless yaml_base && File.exist?("#{yaml_base}/table16.yaml")
    end

    let(:table16) { YAML.load_file("#{yaml_base}/table16.yaml") }
    let(:table3)  { YAML.load_file("#{yaml_base}/table3.yaml") }

    it "generated data matches reference Table 3 within tolerance" do
      profile = Atmospheris::Iso5878::AtmosphereModelRegistry.create("15-annual", table16)
      geometric_alts = table3["rows-h"].map { |r| r["geometrical-altitude"] }

      export = described_class.new(
        profile,
        table_id: "atmosphere-table-3",
        title_en: table3["title-en"],
        geometric_altitudes: geometric_alts
      )
      computed = export.generate
      errors = []

      table3["rows-h"].each_with_index do |ref_row, i|
        comp_row = computed["rows-h"][i]
        next unless comp_row

        # Temperature check (±0.2 K for 15-annual)
        ref_t = ref_row["temperature-K"].to_f
        comp_t = comp_row["temperature-K"].to_f
        if (ref_t - comp_t).abs > 1.0
          errors << "H=#{ref_row["geopotential-altitude"]}m T: ref=#{ref_t}, computed=#{comp_t.round(3)}"
        end

        # Pressure check (relative 0.3% or absolute 1 mbar)
        next unless ref_row["p-mbar"]

        ref_p = ref_row["p-mbar"].to_f
        comp_p = comp_row["p-mbar"].to_f
        tol = [ref_p.abs * 0.005, 1.0].max
        if (ref_p - comp_p).abs > tol
          errors << "H=#{ref_row["geopotential-altitude"]}m P: ref=#{ref_p}, computed=#{comp_p.round(3)}"
        end
      end

      expect(errors).to be_empty,
                        "Table 3 export mismatches:\n#{errors.first(5).join("\n")}"
    end
  end
end

RSpec.describe Atmospheris::Export::Iso5878::WindTableExport do
  let(:sample_wind_data) do
    {
      "id" => "wind-table-1",
      "title-en" => "Test Wind Table",
      "rows" => [
        {
          "angle-low" => 0,
          "angle-high" => 20,
          "direction" => "N",
          "month" => "January",
          "values" => [
            {
              "geopotential-altitude" => 0,
              "Vx" => -2.9,
              "Vy" => -1.6,
              "Vsa" => 5.5,
              "sigma-r" => 3.0,
              "nu-max" => nil,
              "Vsc" => nil,
              "Vsc-1-low" => nil,
              "Vsc-1-high" => nil,
              "Vsc-10-low" => nil,
              "Vsc-10-high" => nil,
              "Vsc-20-low" => nil,
              "Vsc-20-high" => nil
            }
          ]
        }
      ]
    }
  end

  let(:export) { described_class.new(sample_wind_data) }

  describe "#generate" do
    subject(:result) { export.generate }

    it "preserves metadata" do
      expect(result["id"]).to eq("wind-table-1")
      expect(result["title-en"]).to eq("Test Wind Table")
    end

    it "preserves zone structure" do
      expect(result["rows"].length).to eq(1)
      expect(result["rows"][0]["angle-low"]).to eq(0)
    end

    it "fills in Vsc when nil" do
      obs = result["rows"][0]["values"][0]
      expect(obs["Vsc"]).not_to be_nil
      expect(obs["Vsc"]).to be > 0
    end

    it "fills in percentile bounds when nil" do
      obs = result["rows"][0]["values"][0]
      %w[Vsc-1-low Vsc-1-high Vsc-10-low Vsc-10-high Vsc-20-low Vsc-20-high].each do |key|
        expect(obs[key]).not_to be_nil, "Expected #{key} to be filled"
      end
    end

    it "preserves empirical fields" do
      obs = result["rows"][0]["values"][0]
      expect(obs["Vx"]).to eq(-2.9)
      expect(obs["Vy"]).to eq(-1.6)
      expect(obs["sigma-r"]).to eq(3.0)
    end

    it "does not overwrite existing computed fields" do
      data = sample_wind_data
      data["rows"][0]["values"][0]["Vsc"] = 99.9
      result = described_class.new(data).generate
      obs = result["rows"][0]["values"][0]
      expect(obs["Vsc"]).to eq(99.9)
    end

    it "skips rows with nil sigma-r" do
      data = sample_wind_data
      data["rows"][0]["values"][0]["sigma-r"] = nil
      result = described_class.new(data).generate
      obs = result["rows"][0]["values"][0]
      expect(obs["Vsc"]).to be_nil
    end
  end

  describe "cross-validation against Wind Table 1 YAML" do
    let(:yaml_path) do
      # Allow overriding for standard-source cross-checks, but default to vendored fixture
      candidates = [
        ENV["ISO5878_YAML_ROOT"] && File.expand_path("04-yaml/table1.yaml", ENV["ISO5878_YAML_ROOT"]),
        File.expand_path("../../fixtures/iso-5878-2025/yaml/table1.yaml", __dir__)
      ].compact
      candidates.find { |p| File.exist?(p) }
    end

    before do
      skip "Wind YAML not found at #{yaml_path}" unless yaml_path
    end

    let(:wind_data) { YAML.load_file(yaml_path) }

    it "augmented Vsc values match tabulated values within ±4.0 m/s" do
      result = described_class.new(wind_data).generate
      errors = []

      wind_data["rows"].each_with_index do |zone, zi|
        zone["values"].each_with_index do |obs, oi|
          next if obs["Vsc"].nil? || obs["sigma-r"].nil? || obs["sigma-r"] == 0

          ref_vsc = obs["Vsc"].to_f
          comp_vsc = result["rows"][zi]["values"][oi]["Vsc"].to_f
          next unless (ref_vsc - comp_vsc).abs > 4.0

          errors << "#{zone["angle-low"]}-#{zone["angle-high"]}° #{zone["month"]} " \
                    "alt=#{obs["geopotential-altitude"]}km: " \
                    "tabulated=#{ref_vsc}, computed=#{comp_vsc.round(1)}"
        end
      end

      expect(errors).to be_empty, "Vsc mismatches:\n#{errors.first(10).join("\n")}"
    end
  end
end
