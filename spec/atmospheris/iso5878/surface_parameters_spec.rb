# frozen_string_literal: true

require "spec_helper"
require "atmospheris/iso5878/surface_parameters"

RSpec.describe Atmospheris::Iso5878::SurfaceParameters do
  # Reference values from ISO 5878 Table 2
  # { latitude => { g0 (m/s²), r_phi (km) } }
  # NOTE: Lambert's equation (Eq. 0) gives g0=9.80616 at 45°, but ISO 5878
  # states "For 45°N, values are taken from ISO 2533" giving g0=9.80665.
  # The formula values below are what Lambert's equation actually computes.
  LAMBERT_EXPECTED = {
    15 => { g0: 9.78381, r_phi_km: 6337.84 },
    30 => { g0: 9.79324, r_phi_km: 6345.65 },
    45 => { g0: 9.80616, r_phi_km: 6356.36 },  # Lambert output (not ISA override)
    60 => { g0: 9.81911, r_phi_km: 6367.10 },
    80 => { g0: 9.83051, r_phi_km: 6376.56 },
  }.freeze

  LAMBERT_EXPECTED.each do |lat, expected|
    context "at #{lat} degrees" do
      subject(:params) { described_class.new(lat) }

      describe "#gravity_at_sea_level" do
        it "matches Lambert's equation output within ±0.00005 m/s²" do
          expect(params.gravity_at_sea_level).to be_within(0.00005).of(expected[:g0])
        end
      end

      describe "#nominal_earth_radius" do
        it "matches Eq. 13 output within ±0.1 km" do
          r_km = params.nominal_earth_radius / 1000.0
          expect(r_km).to be_within(0.1).of(expected[:r_phi_km])
        end
      end
    end
  end

  describe "cross-latitude properties" do
    it "gravity increases with latitude (equator to pole)" do
      params = [15, 30, 45, 60, 80].map { |l| described_class.new(l) }
      g_values = params.map(&:gravity_at_sea_level)
      expect(g_values).to eq(g_values.sort)
    end

    it "earth radius increases with latitude" do
      params = [15, 30, 45, 60, 80].map { |l| described_class.new(l) }
      r_values = params.map(&:nominal_earth_radius)
      expect(r_values).to eq(r_values.sort)
    end
  end

  describe "#gravity_at_geometric" do
    let(:params) { described_class.new(45) }

    it "equals Lambert g0 at h=0 for 45°" do
      # Lambert gives 9.80616, not ISA 9.80665 (ISA override handled by registry)
      expect(params.gravity_at_geometric(0)).to be_within(1e-8).of(9.80616)
    end

    it "decreases with altitude" do
      g0 = params.gravity_at_geometric(0)
      g10 = params.gravity_at_geometric(10_000)
      g80 = params.gravity_at_geometric(80_000)
      expect(g0).to be > g10
      expect(g10).to be > g80
    end
  end

  describe "altitude conversions" do
    [15, 30, 45, 60, 80].each do |lat|
      context "at #{lat} degrees" do
        let(:params) { described_class.new(lat) }

        it "h->H->h round-trip is identity" do
          [0, 1000, 5000, 11_000, 25_000, 50_000, 80_000].each do |h_m|
            gp = params.geopotential_from_geometric(h_m)
            h_back = params.geometric_from_geopotential(gp)
            expect(h_back).to be_within(1e-6).of(h_m)
          end
        end

        it "H->h->H round-trip is identity" do
          [0, 1000, 5000, 11_000, 25_000, 50_000, 80_000].each do |gp_m|
            h = params.geometric_from_geopotential(gp_m)
            gp_back = params.geopotential_from_geometric(h)
            expect(gp_back).to be_within(1e-6).of(gp_m)
          end
        end
      end
    end

    it "geometric altitude equals geopotential at sea level" do
      params = described_class.new(45)
      expect(params.geometric_from_geopotential(0)).to eq(0)
      expect(params.geopotential_from_geometric(0)).to eq(0)
    end
  end
end
