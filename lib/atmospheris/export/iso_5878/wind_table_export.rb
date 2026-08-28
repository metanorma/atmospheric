# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso5878
      # Takes the empirical wind YAML data (Table 1), computes derived fields
      # using WindObservation, and returns augmented YAML with calculated
      # columns filled in where they are nil.
      #
      # Empirical fields (Vx, Vy, sigma-r, Vsa, nu-max) are never overwritten.
      # Only blank computed fields (Vsc, percentile bounds) are filled.
      #
      # @example
      #   wind_data = YAML.load_file('04-yaml/table1.yaml')
      #   augmented = WindTableExport.new(wind_data).generate
      #   File.write('04-yaml/table1-computed.yaml', YAML.dump(augmented))
      class WindTableExport
        # @param wind_yaml_data [Hash] loaded from table1.yaml
        def initialize(wind_yaml_data)
          @source = wind_yaml_data
        end

        # @return [Hash] augmented YAML data with computed fields filled in
        def generate
          result = @source.dup
          result["rows"] = result["rows"].map do |zone_row|
            augment_zone(zone_row)
          end
          result
        end

        private

        def augment_zone(zone_row)
          zone_row.dup.tap do |row|
            row["values"] = row["values"].map do |obs_row|
              augment_observation(obs_row, zone_row)
            end
          end
        end

        def augment_observation(obs, zone_row)
          vx = obs["Vx"]
          sigma_r = obs["sigma-r"]
          return obs.dup if vx.nil? || sigma_r.nil?

          sigma_r_f = sigma_r.to_f
          return obs.dup if sigma_r_f <= 0

          use_abs_vx = zone_row["angle-low"].to_i >= 20
          wind = ::Atmospheris::Iso5878::WindObservation.new(
            geopotential_altitude: obs["geopotential-altitude"],
            vx: vx.to_f,
            vy: (obs["Vy"] || 0).to_f,
            sigma_r: sigma_r_f,
            use_absolute_vx: use_abs_vx
          )

          obs.dup.tap do |o|
            o["Vsc"] = round1(wind.vsc) if obs["Vsc"].nil?

            bounds = wind.percentile_bounds
            o["Vsc-1-low"]  = round1(bounds[1].low) if obs["Vsc-1-low"].nil?
            o["Vsc-1-high"] = round1(bounds[1].high)   if obs["Vsc-1-high"].nil?
            o["Vsc-10-low"] = round1(bounds[10].low)   if obs["Vsc-10-low"].nil?
            o["Vsc-10-high"] = round1(bounds[10].high) if obs["Vsc-10-high"].nil?
            o["Vsc-20-low"] = round1(bounds[20].low) if obs["Vsc-20-low"].nil?
            o["Vsc-20-high"] = round1(bounds[20].high) if obs["Vsc-20-high"].nil?
          end
        end

        def round1(v)
          (v * 10).round / 10.0
        end
      end
    end
  end
end
