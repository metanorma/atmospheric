# frozen_string_literal: true

module Atmospheris
  module Iso5878
    # Encapsulates a single altitude-level wind observation with its
    # empirically measured parameters and lazily computed derived statistics.
    #
    # Empirical inputs: Vx, Vy, sigma_r, Vsa (optional), nu_max (optional)
    # Derived outputs: Vr, theta, Vsc, percentile bounds
    #
    # @example
    #   obs = WindObservation.new(
    #     geopotential_altitude: 1000,
    #     vx: -3.9, vy: -1.2, sigma_r: 5.9,
    #     vsa: 7.6
    #   )
    #   obs.vr          # => 4.08
    #   obs.vsc         # => 6.03 (calculated)
    #   obs.distribution.percentile_bounds[1].high  # => 14.7
    class WindObservation
      attr_reader :geopotential_altitude, :vx, :vy, :sigma_r, :vsa, :nu_max

      # @param geopotential_altitude [Numeric] altitude in metres
      # @param vx [Numeric] mean zonal wind component (m/s)
      # @param vy [Numeric] mean meridional wind component (m/s)
      # @param sigma_r [Numeric] standard deviation of vector mean wind (m/s)
      # @param vsa [Numeric, nil] observed scalar mean speed (m/s)
      # @param nu_max [Numeric, nil] max observed speed once in 10 years (m/s)
      # @param use_absolute_vx [Boolean] for zones > 20°N where Vy ≈ 0
      def initialize(geopotential_altitude:, vx:, vy:, sigma_r:, vsa: nil, nu_max: nil, use_absolute_vx: false)
        @geopotential_altitude = geopotential_altitude.to_f
        @vx = vx.to_f
        @vy = vy.to_f
        @sigma_r = sigma_r.to_f
        @vsa = vsa
        @nu_max = nu_max
        @use_absolute_vx = use_absolute_vx
      end

      # Magnitude of the vector mean wind.
      # For zones > 20°N, uses |Vx| as specified in ISO 5878 Section 5.4.
      # @return [Float]
      def vr
        @vr ||= @use_absolute_vx ? @vx.abs : Math.sqrt(@vx**2 + @vy**2)
      end

      # Direction of the vector mean wind (radians from east).
      # @return [Float]
      def theta
        @theta ||= Math.atan2(@vy, @vx)
      end

      # The Rice distribution for this observation level.
      # Lazily constructed and cached.
      # @return [RiceDistribution]
      def distribution
        @distribution ||= RiceDistribution.new(vr: vr, sigma_r: @sigma_r)
      end

      # Calculated scalar mean wind speed (Vsc).
      # @return [Float]
      def vsc
        @vsc ||= distribution.mean
      end

      # Calculated percentile bounds.
      # @return [Hash{Integer => PercentilePair}]
      def percentile_bounds
        @percentile_bounds ||= distribution.percentile_bounds
      end

      # Full derived result as a WindDerivedFields struct (legacy API compat).
      # @return [WindDerivedFields]
      def derived_fields
        @derived_fields ||= WindDerivedFields.new(
          vr: vr,
          sigma: distribution.sigma,
          vsc: vsc,
          percentiles: percentile_bounds
        )
      end
    end
  end
end
