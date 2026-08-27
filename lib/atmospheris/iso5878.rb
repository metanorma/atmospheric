# frozen_string_literal: true

# ISO 5878 — Reference atmospheres for aerospace use
# Wind characteristics: circular normal (Rice) distribution
# Implements Section 5.4 calculation methods

module Atmospheris
  module Iso5878
    autoload :SurfaceParameters, "atmospheris/iso5878/surface_parameters"
    autoload :AtmosphereProfile, "atmospheris/iso5878/atmosphere_profile"
    autoload :TemperatureLayerStructure, "atmospheris/iso5878/atmosphere_profile"
    autoload :AtmosphereModelRegistry, "atmospheris/iso5878/model_registry"
    autoload :RiceDistribution, "atmospheris/iso5878/rice_distribution"
    autoload :WindObservation, "atmospheris/iso5878/wind_observation"

    # --- Bessel functions (Abramowitz & Stegun polynomial approximations) ---
    # Relative error < 1.6x10^-7

    # Modified Bessel function of the first kind, order zero (I_0).
    # Polynomial approximation from A&S 9.8.1/9.8.2.
    def self.bessel_i0(x)
      ax = x.abs
      if ax <= 3.75
        y = (x / 3.75)**2
        1.0 + y * (3.5156229 + y * (3.0899424 + y * (1.2067492 +
          y * (0.2659732 + y * (0.0360768 + y * 0.0045813)))))
      else
        y = 3.75 / ax
        (Math.exp(ax) / Math.sqrt(ax)) * (0.39894228 + y * (0.01328592 +
          y * (0.00225319 + y * (-0.00157565 + y * (0.00916281 +
          y * (-0.02057706 + y * (0.02635537 + y * (-0.01647633 +
          y * 0.00392377))))))))
      end
    end

    # Modified Bessel function of the first kind, order one (I_1).
    # Polynomial approximation from A&S 9.8.3/9.8.4.
    def self.bessel_i1(x)
      ax = x.abs
      if ax <= 3.75
        y = (x / 3.75)**2
        value = ax * (0.5 + y * (0.87890594 + y * (0.51498869 +
          y * (0.15084934 + y * (0.02658733 + y * (0.00301532 +
          y * 0.00032411))))))
        x < 0 ? -value : value
      else
        y = 3.75 / ax
        value = (Math.exp(ax) / Math.sqrt(ax)) * (0.39894228 + y * (-0.03988024 +
          y * (-0.00362018 + y * (0.00163801 + y * (-0.01031555 +
          y * (0.02282967 + y * (-0.02895312 + y * (0.01787654 +
          y * -0.00420059))))))))
        x < 0 ? -value : value
      end
    end

    # --- Rice (circular normal) distribution ---
    # ISO 5878 Eq. 3 PDF:
    #   f(v) = (2v/sigma_r^2) exp(-(v^2 + V_r^2)/sigma_r^2) I_0(2vV_r/sigma_r^2)

    # Rice distribution PDF per ISO 5878 Eq. 3.
    def self.rice_pdf(nu, vr, sigma_r)
      return 0.0 if nu <= 0
      sr2 = sigma_r * sigma_r
      ratio = 2.0 * nu * vr / sr2
      (2.0 * nu / sr2) * Math.exp(-(nu * nu + vr * vr) / sr2) * bessel_i0(ratio)
    end

    # Rice distribution CDF via adaptive Simpson quadrature on the PDF.
    def self.rice_cdf(x, vr, sigma_r)
      return 0.0 if x <= 0
      sigma = sigma_r / Math.sqrt(2)

      # Rayleigh limit for very small Vr
      if vr < sigma * 1e-6
        return 1.0 - Math.exp(-x * x / (2.0 * sigma * sigma))
      end

      adaptive_simpson(
        ->(t) { rice_pdf(t, vr, sigma_r) },
        0.0, x, 1e-10, 30
      ).clamp(0.0, 1.0)
    end

    # Rice distribution inverse CDF (quantile function) via bisection.
    def self.rice_inv_cdf(p, vr, sigma_r)
      return 0.0 if p <= 0
      return Float::INFINITY if p >= 1
      sigma = sigma_r / Math.sqrt(2)

      lo = 0.0
      hi = sigma * Math.sqrt(-2.0 * Math.log(1 - p)) * 3 + vr + 4 * sigma

      100.times do
        mid = (lo + hi) / 2.0
        cdf = rice_cdf(mid, vr, sigma_r)
        if cdf < p
          lo = mid
        else
          hi = mid
        end
        break if hi - lo < 1e-10
      end
      (lo + hi) / 2.0
    end

    # Rice distribution mean (scalar wind speed Vsc per ISO 5878 Eq. 4).
    def self.rice_mean(vr, sigma_r)
      sigma = sigma_r / Math.sqrt(2)
      lambda = vr * vr / (4.0 * sigma * sigma)
      prefactor = sigma * Math.sqrt(Math::PI / 2.0) * Math.exp(-lambda)
      b0 = bessel_i0(lambda)
      b1 = bessel_i1(lambda)
      prefactor * ((1.0 + 2.0 * lambda) * b0 + 2.0 * lambda * b1)
    end

    # --- Main API (legacy) ---

    WindDerivedFields = Struct.new(:vr, :sigma, :vsc, :percentiles, keyword_init: true)
    PercentilePair = Struct.new(:low, :high, keyword_init: true)

    # Compute wind distribution derived fields from observed parameters
    # using the circular normal (Rice) distribution per ISO 5878 Section 5.4.
    #
    # @param vx [Float] Mean zonal component of the wind (m/s)
    # @param vy [Float] Mean meridional component of the wind (m/s)
    # @param sigma_r [Float] Standard deviation of the vector mean wind (m/s)
    # @param use_absolute_vx [Boolean] For zones > 20degN where Vy ~ 0
    def self.compute_wind_derived(vx, vy, sigma_r, use_absolute_vx: false)
      vr = use_absolute_vx ? vx.abs : Math.sqrt(vx * vx + vy * vy)
      sigma = sigma_r / Math.sqrt(2)

      WindDerivedFields.new(
        vr: vr,
        sigma: sigma,
        vsc: rice_mean(vr, sigma_r),
        percentiles: {
          1 => PercentilePair.new(
            low: rice_inv_cdf(0.01, vr, sigma_r),
            high: rice_inv_cdf(0.99, vr, sigma_r)
          ),
          10 => PercentilePair.new(
            low: rice_inv_cdf(0.10, vr, sigma_r),
            high: rice_inv_cdf(0.90, vr, sigma_r)
          ),
          20 => PercentilePair.new(
            low: rice_inv_cdf(0.20, vr, sigma_r),
            high: rice_inv_cdf(0.80, vr, sigma_r)
          )
        }
      )
    end

    private

    # Adaptive Simpson quadrature (iterative).
    def self.adaptive_simpson(f, a, b, tol, max_depth)
      fa = f.call(a)
      fb = f.call(b)
      m = (a + b) / 2.0
      fm = f.call(m)
      whole = (b - a) / 6.0 * (fa + 4.0 * fm + fb)

      stack = [[a, b, fa, fb, fm, whole, tol, 0]]
      total = 0.0

      while (item = stack.pop)
        la, lb, lfa, lfb, lfm, s_whole, l_tol, depth = item
        lm = (la + lb) / 2.0
        h = lb - la

        lm1 = (la + lm) / 2.0
        lm2 = (lm + lb) / 2.0
        fm1 = f.call(lm1)
        fm2 = f.call(lm2)
        s_left = h / 12.0 * (lfa + 4.0 * fm1 + lfm)
        s_right = h / 12.0 * (lfm + 4.0 * fm2 + lfb)
        s_refined = s_left + s_right

        if depth >= max_depth || (s_refined - s_whole).abs <= 15.0 * l_tol
          total += s_refined + (s_refined - s_whole) / 15.0
        else
          stack.push([lm, lb, lfm, lfb, fm2, s_right, l_tol / 2.0, depth + 1])
          stack.push([la, lm, lfa, lfm, fm1, s_left, l_tol / 2.0, depth + 1])
        end
      end

      [[0.0, total].max, 1.0].min
    end
  end
end
