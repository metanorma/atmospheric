# frozen_string_literal: true

module Atmospheris
  module Iso5878
    # Encapsulates a single Rice (circular normal) distribution instance
    # with fixed parameters (Vr, sigma_r).
    #
    # Wraps the existing module-level methods (bessel_i0, rice_pdf, etc.)
    # in an object-oriented interface, enabling lazy caching and clean
    # composition by WindObservation.
    #
    # @example
    #   dist = RiceDistribution.new(vr: 3.9, sigma_r: 5.9)
    #   dist.mean           # => 6.03
    #   dist.quantile(0.99) # => 14.7
    #   dist.percentile_bounds
    class RiceDistribution
      attr_reader :vr, :sigma_r, :sigma

      # @param vr [Numeric] magnitude of vector mean wind (m/s)
      # @param sigma_r [Numeric] standard deviation of vector mean wind (m/s)
      def initialize(vr:, sigma_r:)
        @vr = vr.to_f
        @sigma_r = sigma_r.to_f
        @sigma = @sigma_r / Math.sqrt(2)
      end

      # Probability density at wind speed nu.
      # @param nu [Numeric] wind speed (m/s)
      # @return [Float]
      def pdf(nu)
        Iso5878.rice_pdf(nu, vr, sigma_r)
      end

      # Cumulative distribution function at wind speed x.
      # @param x [Numeric] wind speed (m/s)
      # @return [Float] probability in [0, 1]
      def cdf(x)
        Iso5878.rice_cdf(x, vr, sigma_r)
      end

      # Inverse CDF (quantile function) for probability p.
      # @param p [Numeric] probability in (0, 1)
      # @return [Float] wind speed (m/s)
      def quantile(p)
        Iso5878.rice_inv_cdf(p, vr, sigma_r)
      end

      # Analytical mean of the Rice distribution (Eq. 4).
      # This is the calculated scalar mean wind speed Vsc.
      # @return [Float] mean wind speed (m/s)
      def mean
        @mean ||= Iso5878.rice_mean(vr, sigma_r)
      end

      # Percentile bounds as defined in ISO 5878.
      # Returns hash mapping percentage to PercentilePair (low/high).
      # @return [Hash{Integer => PercentilePair}]
      def percentile_bounds
        @percentile_bounds ||= {
          1 => PercentilePair.new(
            low: quantile(0.01),
            high: quantile(0.99)
          ),
          10 => PercentilePair.new(
            low: quantile(0.10),
            high: quantile(0.90)
          ),
          20 => PercentilePair.new(
            low: quantile(0.20),
            high: quantile(0.80)
          )
        }
      end
    end
  end
end
