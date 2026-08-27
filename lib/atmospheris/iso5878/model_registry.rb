# frozen_string_literal: true

module Atmospheris
  module Iso5878
    # Factory for constructing AtmosphereProfile instances from model identifiers.
    #
    # Maps model IDs (e.g. "15-annual", "60-warm") to their latitude, season,
    # and temperature layer structure key. Surface conditions are looked up
    # from Table 2 data. Layer structures are loaded from YAML data (Table 16/19).
    #
    # Open/closed: new models can be added to MODELS without modifying
    # AtmosphereProfile or TemperatureLayerStructure.
    class AtmosphereModelRegistry
      # Model definitions: maps model_id to configuration
      MODELS = {
        "15-annual" => { latitude: 15,  season: :annual, layers_key: :"rows-15" },
        "30-winter" => { latitude: 30,  season: :winter, layers_key: :"rows-30-w" },
        "30-summer" => { latitude: 30,  season: :summer, layers_key: :"rows-30-s" },
        "45-winter" => { latitude: 45,  season: :winter, layers_key: :"rows-45-w" },
        "45-summer" => { latitude: 45,  season: :summer, layers_key: :"rows-45-s" },
        "60-winter" => { latitude: 60,  season: :winter, layers_key: :"rows-60-w" },
        "60-summer" => { latitude: 60,  season: :summer, layers_key: :"rows-60-s" },
        "60-warm"   => { latitude: 60,  season: :winter, layers_key: :"rows-60-warm" },
        "60-cold"   => { latitude: 60,  season: :winter, layers_key: :"rows-60-cold" },
        "80-winter" => { latitude: 80,  season: :winter, layers_key: :"rows-80-w" },
        "80-summer" => { latitude: 80,  season: :summer, layers_key: :"rows-80-s" },
        "80-warm"   => { latitude: 80,  season: :winter, layers_key: :"rows-80-warm" },
        "80-cold"   => { latitude: 80,  season: :winter, layers_key: :"rows-80-cold" },
      }.freeze

      # Surface conditions from ISO 5878 Table 2.
      # Pressures in Pa, temperatures in K.
      SURFACE_CONDITIONS = {
        15 => {
          annual: { T: 299.650, P: 101325.0 }
        },
        30 => {
          winter: { T: 283.150, P: 102050.0 },
          summer: { T: 297.150, P: 101400.0 }
        },
        45 => {
          winter: { T: 272.650, P: 101800.0 },
          summer: { T: 291.150, P: 101350.0 }
        },
        60 => {
          winter: { T: 256.150, P: 101300.0 },
          summer: { T: 282.150, P: 101020.0 }
        },
        80 => {
          winter: { T: 248.950, P: 101380.0 },
          summer: { T: 276.650, P: 101200.0 }
        }
      }.freeze

      # Construct an AtmosphereProfile for the given model ID.
      #
      # @param model_id [String] e.g. "15-annual", "60-warm"
      # @param layers_data [Hash] YAML data from table16.yaml or table19.yaml
      #   Must contain the key matching the model's layers_key
      # @return [AtmosphereProfile]
      def self.create(model_id, layers_data)
        config = MODELS.fetch(model_id) do
          raise ArgumentError, "Unknown ISO 5878 model: #{model_id}. " \
                               "Available: #{MODELS.keys.join(', ')}"
        end

        surface = SURFACE_CONDITIONS.dig(config[:latitude], config[:season])
        unless surface
          raise ArgumentError, "No surface conditions for #{config[:latitude]}° #{config[:season]}"
        end

        raw_rows = layers_data[config[:layers_key].to_s]
        unless raw_rows
          raise ArgumentError, "Layer data key '#{config[:layers_key]}' not found in provided data"
        end

        # Normalize YAML keys to symbols
        normalized = raw_rows.map do |row|
          {
            geopotential_altitude: row["geopotential-altitude"] || row[:geopotential_altitude],
            temperature_K: row["temperature-K"] || row[:temperature_K]
          }
        end

        tls = TemperatureLayerStructure.from_yaml_rows(normalized)
        params = SurfaceParameters.new(config[:latitude])

        AtmosphereProfile.new(
          surface_params: params,
          surface_temperature: surface[:T],
          surface_pressure: surface[:P],
          layers: tls.to_a
        )
      end

      # List all available model IDs.
      # @return [Array<String>]
      def self.model_ids
        MODELS.keys
      end
    end
  end
end
