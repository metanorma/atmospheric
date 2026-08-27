# frozen_string_literal: true

require "atmospheris/isa"

module Atmospheris
  module Iso5878
    # Generalized ISA engine for ISO 5878 reference atmospheres.
    #
    # Extends Isa::Algorithms (open/closed principle) by injecting custom
    # temperature layer structures and latitude-dependent surface conditions.
    # All barometric formula methods (pressure, density, etc.) are inherited
    # and automatically use the custom configuration.
    #
    # One AtmosphereProfile instance = one atmosphere model (e.g. "15 annual"
    # or "60N winter warm regime").
    #
    # @example
    #   params = SurfaceParameters.new(15)
    #   layers = Iso5878::TemperatureLayerStructure.from_yaml_rows(yaml_rows)
    #   profile = AtmosphereProfile.new(
    #     surface_params: params,
    #     surface_temperature: 299.65,
    #     surface_pressure: 101325.0,
    #     layers: layers.to_a
    #   )
    #   profile.pressure_from_geopotential_mbar(5000)
    class AtmosphereProfile < Isa::Algorithms
      R_SPECIFIC = 287.05287

      attr_reader :surface_params, :surface_temperature, :surface_pressure, :model_layers

      # @param surface_params [SurfaceParameters]
      # @param surface_temperature [Numeric] T at sea level (K)
      # @param surface_pressure [Numeric] P at sea level (Pa)
      # @param layers [Array<Hash>] ISA-format temperature layers
      #   [{ H: 0.0, T: 299.65, B: -0.006 }, ...]
      #   H in metres, T in Kelvin, B in K/m. Last layer has no :B key.
      def initialize(surface_params:, surface_temperature:, surface_pressure:, layers:)
        @surface_params = surface_params
        @surface_temperature = surface_temperature.to_f
        @surface_pressure = surface_pressure.to_f
        @model_layers = layers
        set_precision(:normal)
      end

      private

      # Override: inject latitude-specific constants instead of ISA defaults.
      def make_constants
        g0 = surface_params.gravity_at_sea_level
        radius = surface_params.nominal_earth_radius
        p_n = surface_pressure
        t_n = surface_temperature
        r_star = 8.31432
        rho_n = p_n / (R_SPECIFIC * t_n)
        molar = rho_n * r_star * t_n / p_n

        @constants = {
          g_n: g0,
          N_A: 6.02257e23,
          p_n: p_n,
          rho_n: rho_n,
          T_n: t_n,
          R_star: r_star,
          radius: radius,
          k: 1.4,
          M: molar,
          R: r_star / molar
        }

        @sqrt2 = Math.sqrt(2)
        @pi = Math::PI
      end

      # Override: locate layer index using injected model_layers.
      def locate_lower_layer(geopotential_alt)
        return 0 if geopotential_alt < model_layers[0][:H]
        i = model_layers.length - 1
        return i - 1 if geopotential_alt >= model_layers[i][:H]
        model_layers.each_with_index do |layer, ind|
          return ind - 1 if layer[:H] > geopotential_alt
        end
        nil
      end

      # Override: pressure layer base values computed from injected layers.
      def pressure_layers
        return @pressure_layers if @pressure_layers

        p = []
        model_layers.each_with_index do |_x, i|
          last_i = i.zero? ? 0 : i - 1
          last_layer = model_layers[last_i]
          beta = last_layer[:B] || 0.0

          if last_layer[:H] <= 0
            p_b = @constants[:p_n]
            h_b = 0.0
            t_b = @constants[:T_n]
          else
            p_b = p[last_i]
            h_b = last_layer[:H]
            t_b = last_layer[:T]
          end

          current_layer = model_layers[i]
          h_curr = current_layer[:H]
          dh = h_curr - h_b

          p[i] = if beta.zero?
                   pressure_formula_beta_zero(p_b, current_layer[:T], dh)
                 else
                   pressure_formula_beta_nonzero(p_b, beta, t_b, dh)
                 end
        end

        @pressure_layers = p
      end

      # --- Public method overrides (must remain public) ---

      # Override: temperature lookup uses injected model_layers.
      def temperature_at_layer_from_geopotential(geopotential_alt)
        idx = locate_lower_layer(geopotential_alt)
        layer = model_layers[idx]
        beta = layer[:B] || 0.0
        t_b = layer[:T]
        h_b = layer[:H]
        t_b + beta * (geopotential_alt - h_b)
      end

      # Override: pressure at altitude uses injected model_layers.
      def pressure_from_geopotential(geopotential_alt)
        i = locate_lower_layer(geopotential_alt)
        layer = model_layers[i]
        beta = layer[:B] || 0.0
        h_b = layer[:H]
        t_b = layer[:T]
        temp = temperature_at_layer_from_geopotential(geopotential_alt)
        p_b = pressure_layers[i]
        dh = geopotential_alt - h_b

        if beta.zero?
          pressure_formula_beta_zero(p_b, temp, dh)
        else
          pressure_formula_beta_nonzero(p_b, beta, t_b, dh)
        end
      end

      public :temperature_at_layer_from_geopotential, :pressure_from_geopotential
    end

    # Converts YAML breakpoint data (Table 16 / Table 19 format) into
    # the ISA-compatible layer format used by AtmosphereProfile.
    #
    # Input format (YAML rows):
    #   [{ geopotential_altitude: 0.0, temperature_K: 299.65 },
    #    { geopotential_altitude: 2.25, temperature_K: 286.15 },
    #    ...]
    #
    # Output format (ISA layers):
    #   [{ H: 0.0, T: 299.65, B: -0.006 },
    #    { H: 2250.0, T: 286.15, B: 0.0032 },
    #    ...]
    #
    # Gradients (B) are computed from consecutive temperature/altitude pairs
    # rather than read from the YAML gradient column, ensuring consistency
    # with the specified temperature breakpoints.
    class TemperatureLayerStructure
      attr_reader :layers

      # @param yaml_rows [Array<Hash>] breakpoint data from table16/19 YAML
      #   Keys: :geopotential_altitude (km), :temperature_K (K)
      def initialize(yaml_rows)
        @layers = build_layers(yaml_rows)
      end

      # Construct from a YAML row subset (e.g., yaml_data["rows-15"])
      # @param rows [Array<Hash>]
      # @return [TemperatureLayerStructure]
      def self.from_yaml_rows(rows)
        new(rows)
      end

      # @return [Array<Hash>] ISA-format layers
      def to_a
        @layers
      end

      private

      def build_layers(rows)
        layers = []
        rows.each_with_index do |row, i|
          h_m = row[:geopotential_altitude].to_f * 1000.0 # km -> m
          t_k = row[:temperature_K].to_f

          if i < rows.length - 1
            next_row = rows[i + 1]
            next_h = next_row[:geopotential_altitude].to_f * 1000.0
            next_t = next_row[:temperature_K].to_f
            dh = next_h - h_m
            beta = dh.abs < 1e-12 ? 0.0 : (next_t - t_k) / dh # K/m
            layers << { H: h_m, T: t_k, B: beta }
          else
            # Last breakpoint — no layer above it
            layers << { H: h_m, T: t_k }
          end
        end
        layers
      end
    end
  end
end
