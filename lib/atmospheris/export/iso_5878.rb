# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso5878
      autoload :AtmosphereProfileExport,
        "atmospheris/export/iso_5878/atmosphere_profile_export"
      autoload :WindTableExport,
        "atmospheris/export/iso_5878/wind_table_export"

      class << self
        # Generate atmosphere profile YAML data for a given model.
        #
        # @param model_id [String] e.g. "15-annual", "60-warm"
        # @param layers_data [Hash] YAML data from table16.yaml or table19.yaml
        # @param table_id [String] YAML id field
        # @param title_en [String] YAML title-en field
        # @param geometric_altitudes [Array<Integer>] geometric altitudes in metres
        # @return [Hash] YAML-serializable data
        def generate_atmosphere_profile(model_id, layers_data, table_id:, title_en:, geometric_altitudes:)
          profile = ::Atmospheris::Iso5878::AtmosphereModelRegistry.create(model_id, layers_data)
          AtmosphereProfileExport.new(
            profile,
            table_id: table_id,
            title_en: title_en,
            geometric_altitudes: geometric_altitudes
          ).generate
        end

        # Augment wind observation YAML data with computed derived fields.
        #
        # @param wind_yaml_data [Hash] loaded from table1.yaml
        # @return [Hash] augmented data (computed fields filled where nil)
        def generate_wind_table(wind_yaml_data)
          WindTableExport.new(wind_yaml_data).generate
        end
      end
    end
  end
end
