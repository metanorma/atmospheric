# frozen_string_literal: true

require "spec_helper"
require "atmospheris/iso5878/rice_distribution"
require "yaml"

RSpec.describe Atmospheris::Iso5878::RiceDistribution do
  describe "Bessel function accuracy" do
    describe "I_0 (bessel_i0)" do
      it "returns 1.0 at x=0" do
        expect(Atmospheris::Iso5878.bessel_i0(0)).to be_within(1e-10).of(1.0)
      end

      it "matches known values" do
        # A&S Table 9.1 reference values
        expect(Atmospheris::Iso5878.bessel_i0(1)).to be_within(1e-6).of(1.266065877)
        expect(Atmospheris::Iso5878.bessel_i0(2)).to be_within(1e-6).of(2.279585302)
        expect(Atmospheris::Iso5878.bessel_i0(3)).to be_within(1e-5).of(4.880792586)
        expect(Atmospheris::Iso5878.bessel_i0(5)).to be_within(1e-4).of(27.23987182)
      end

      it "is symmetric (even function)" do
        [0.5, 1.0, 2.5, 3.75, 7.0].each do |x|
          expect(Atmospheris::Iso5878.bessel_i0(x)).to eq(Atmospheris::Iso5878.bessel_i0(-x))
        end
      end
    end

    describe "I_1 (bessel_i1)" do
      it "returns 0.0 at x=0" do
        expect(Atmospheris::Iso5878.bessel_i1(0)).to be_within(1e-10).of(0.0)
      end

      it "matches known values" do
        expect(Atmospheris::Iso5878.bessel_i1(1)).to be_within(1e-6).of(0.565159104)
        expect(Atmospheris::Iso5878.bessel_i1(2)).to be_within(1e-6).of(1.590636855)
      end

      it "is odd (antisymmetric)" do
        [0.5, 1.0, 2.5, 3.75, 7.0].each do |x|
          expect(Atmospheris::Iso5878.bessel_i1(-x)).to be_within(1e-10).of(-Atmospheris::Iso5878.bessel_i1(x))
        end
      end
    end
  end

  describe "RiceDistribution instance" do
    describe "Rayleigh limit (Vr=0)" do
      let(:dist) { described_class.new(vr: 0.0, sigma_r: 6.0) }

      it "mean equals sigma*sqrt(pi/2)" do
        expected = dist.sigma * Math.sqrt(Math::PI / 2.0)
        expect(dist.mean).to be_within(0.01).of(expected)
      end

      it "CDF matches Rayleigh formula" do
        [1.0, 3.0, 5.0, 10.0, 15.0].each do |x|
          rayleigh = 1.0 - Math.exp(-x * x / (2.0 * dist.sigma * dist.sigma))
          expect(dist.cdf(x)).to be_within(1e-6).of(rayleigh)
        end
      end
    end

    describe "large Vr/sigma limit" do
      let(:dist) { described_class.new(vr: 50.0, sigma_r: 2.0) }

      it "mean approaches Vr" do
        expect(dist.mean).to be_within(0.5).of(50.0)
      end
    end

    describe "CDF properties" do
      let(:dist) { described_class.new(vr: 4.0, sigma_r: 5.9) }

      it "is 0 at x=0" do
        expect(dist.cdf(0)).to eq(0.0)
      end

      it "approaches 1 for large x" do
        expect(dist.cdf(100)).to be_within(1e-6).of(1.0)
      end

      it "is monotonically increasing" do
        cdf_values = (1..30).map { |x| dist.cdf(x) }
        cdf_values.each_cons(2) do |a, b|
          expect(b).to be >= a
        end
      end
    end

    describe "quantile function" do
      let(:dist) { described_class.new(vr: 4.0, sigma_r: 5.9) }

      it "returns 0 for p=0" do
        expect(dist.quantile(0)).to eq(0.0)
      end

      it "CDF(quantile(p)) ≈ p" do
        [0.01, 0.10, 0.20, 0.50, 0.80, 0.90, 0.99].each do |p|
          q = dist.quantile(p)
          expect(dist.cdf(q)).to be_within(1e-6).of(p)
        end
      end

      it "percentiles are ordered" do
        bounds = dist.percentile_bounds
        expect(bounds[1].low).to be < bounds[10].low
        expect(bounds[10].low).to be < bounds[20].low
        expect(bounds[20].low).to be < dist.mean
        expect(dist.mean).to be < bounds[20].high
        expect(bounds[20].high).to be < bounds[10].high
        expect(bounds[10].high).to be < bounds[1].high
      end
    end

    describe "mean accuracy" do
      it "matches numerical integration of PDF" do
        dist = described_class.new(vr: 3.9, sigma_r: 5.9)
        # Numerical integration: integral of x*f(x) dx from 0 to inf
        n_steps = 10_000
        dx = 30.0 / n_steps
        integral = (1...n_steps).sum do |i|
          x = i * dx
          x * dist.pdf(x) * dx
        end
        expect(dist.mean).to be_within(0.05).of(integral)
      end
    end
  end

  describe "cross-validation against Wind Table 1 YAML data" do
    # Load vendored ISO 5878 wind table fixture
    let(:wind_yaml_path) do
      # Allow overriding for standard-source cross-checks, but default to vendored fixture
      candidates = [
        ENV["ISO5878_YAML_ROOT"] && File.expand_path("04-yaml/table1.yaml", ENV["ISO5878_YAML_ROOT"]),
        File.expand_path("../../fixtures/iso-5878-2025/yaml/table1.yaml", __dir__)
      ].compact
      candidates.find { |p| File.exist?(p) }
    end

    let(:wind_data) do
      YAML.load_file(wind_yaml_path)
    end

    before do
      skip "Wind YAML not found at #{wind_yaml_path}" unless wind_yaml_path && File.exist?(wind_yaml_path)
    end

    it "computed Vsc matches tabulated Vsc within ±4.0 m/s" do
      errors = []
      wind_data["rows"].each do |zone|
        angle_low = zone["angle-low"].to_i
        use_abs_vx = angle_low >= 20

        zone["values"].each do |obs|
          next if obs["Vsc"].nil? || obs["sigma-r"].nil? || obs["sigma-r"] == 0

          vx = obs["Vx"].to_f
          vy = obs["Vy"].to_f
          sigma_r = obs["sigma-r"].to_f
          expected_vsc = obs["Vsc"].to_f

          vr = use_abs_vx ? vx.abs : Math.sqrt(vx * vx + vy * vy)
          dist = described_class.new(vr: vr, sigma_r: sigma_r)
          computed_vsc = dist.mean

          next if (computed_vsc - expected_vsc).abs < 4.0

          errors << "#{zone["angle-low"]}-#{zone["angle-high"]}° #{zone["month"]} " \
                    "alt=#{obs["geopotential-altitude"]}km: " \
                    "computed Vsc=#{computed_vsc.round(2)}, " \
                    "tabulated=#{expected_vsc}"
        end
      end

      expect(errors).to be_empty, "Vsc mismatches:\n#{errors.first(10).join("\n")}"
    end

    it "computed percentile bounds match tabulated values within ±6.0 m/s" do
      errors = []
      wind_data["rows"].each do |zone|
        zone["values"].each do |obs|
          next if obs["Vsc-10-low"].nil? || obs["sigma-r"].nil? || obs["sigma-r"] == 0

          vx = obs["Vx"].to_f
          vy = obs["Vy"].to_f
          sigma_r = obs["sigma-r"].to_f
          use_abs_vx = zone["angle-low"].to_i >= 20

          vr = use_abs_vx ? vx.abs : Math.sqrt(vx * vx + vy * vy)
          dist = described_class.new(vr: vr, sigma_r: sigma_r)
          vsc_val = obs["Vsc"] ? obs["Vsc"].to_f : dist.mean
          bounds = dist.percentile_bounds

          [
            ["Vsc-1-low", bounds[1].low],
            ["Vsc-1-high", bounds[1].high],
            ["Vsc-10-low", bounds[10].low],
            ["Vsc-10-high", bounds[10].high],
            ["Vsc-20-low", bounds[20].low],
            ["Vsc-20-high", bounds[20].high]
          ].each do |key, computed|
            next if obs[key].nil?

            expected = obs[key].to_f
            # Skip clearly erroneous data: Vsc-X-low > Vsc (impossible for lower percentile below mean)
            next if key.end_with?("-low") && expected > vsc_val

            next if (computed - expected).abs < 6.0

            errors << "#{zone["angle-low"]}-#{zone["angle-high"]}° #{zone["month"]} " \
                      "alt=#{obs["geopotential-altitude"]}km #{key}: " \
                      "computed=#{computed.round(2)}, tabulated=#{expected}"
          end
        end
      end

      expect(errors).to be_empty, "Percentile mismatches:\n#{errors.first(10).join("\n")}"
    end
  end
end
