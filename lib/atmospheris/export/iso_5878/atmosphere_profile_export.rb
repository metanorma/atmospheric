# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso5878
      # Generates YAML data matching the existing table3.yaml–table15.yaml format.
      #
      # Computes temperature, pressure, and density at specified geometric altitudes
      # using an AtmosphereProfile instance.
      #
      # @example
      #   profile = AtmosphereModelRegistry.create("15-annual", table16_data)
      #   export = AtmosphereProfileExport.new(
      #     profile,
      #     table_id: "atmosphere-table-3",
      #     title_en: "Mean annual values ...",
      #     geometric_altitudes: (0..10_000).step(1000).to_a + (12_000..80_000).step(2000).to_a
      #   )
      #   yaml_data = export.generate
      class AtmosphereProfileExport
        STANDARD_ALTITUDES = (
          (0..10_000).step(1000).to_a + (12_000..80_000).step(2000).to_a
        ).freeze

        # @param profile [Iso5878::AtmosphereProfile]
        # @param table_id [String]
        # @param title_en [String]
        # @param geometric_altitudes [Array<Integer>] geometric altitudes in metres
        def initialize(profile, table_id:, title_en:, geometric_altitudes: STANDARD_ALTITUDES)
          @profile = profile
          @table_id = table_id
          @title_en = title_en
          @geometric_altitudes = geometric_altitudes
        end

        # @return [Hash] YAML-serializable atmosphere profile table data
        def generate
          {
            "id" => @table_id,
            "title-en" => @title_en,
            "title-fr" => "",
            "title-ru" => "",
            "note-en" => "",
            "note-fr" => "",
            "note-ru" => "",
            "rows-h" => @geometric_altitudes.map { |h_m| compute_row(h_m) }
          }
        end

        private

        def compute_row(h_m)
          h_m_f = h_m.to_f
          gp_h = @profile.geopotential_altitude_from_geometric(h_m_f)
          t_k = @profile.temperature_at_layer_from_geopotential(gp_h)
          t_c = t_k - 273.15
          p_mbar = @profile.pressure_from_geopotential_mbar(gp_h)
          rho = @profile.density_from_geopotential(gp_h)

          {
            "geometrical-altitude" => h_m,
            "geopotential-altitude" => gp_h.round,
            "temperature-K" => round3(t_k),
            "temperature-C" => round2(t_c),
            "p-mbar" => scientific_notation(p_mbar),
            "density" => scientific_notation(rho)
          }
        end

        def round2(v)
          (v * 100).round / 100.0
        end

        def round3(v)
          (v * 1000).round / 1000.0
        end

        # Format a float in scientific notation matching YAML convention.
        # e.g. 1013.25 → "1.013250e3", 0.001779 → "1.177987e0"
        def scientific_notation(v)
          v.round(6)
        end
      end
    end
  end
end
