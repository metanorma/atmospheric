# frozen_string_literal: true

module Atmospheris
  module Iso5878
    # Encapsulates latitude-dependent surface parameters for ISO 5878
    # reference atmospheres.
    #
    # Computes gravity at sea level (Lambert's equation, Eq. 0) and nominal
    # earth radius (Eq. 13) from geographic latitude. Provides altitude
    # conversion methods that use latitude-specific gravity and radius.
    #
    # Immutable value object — all derived values are computed from latitude.
    class SurfaceParameters
      G_N = 9.80665 # standard gravity (m/s^2), ISO 2533
      R_SPECIFIC = 287.05287 # specific gas constant (J/(kg*K))

      attr_reader :latitude_deg

      # @param latitude_deg [Numeric] geographic latitude in degrees
      def initialize(latitude_deg)
        @latitude_deg = latitude_deg.to_f
      end

      # Eq. 0 — Lambert's equation for acceleration of free fall at sea level.
      # @return [Float] g_0(phi) in m/s^2
      def gravity_at_sea_level
        phi_rad = @latitude_deg * Math::PI / 180.0
        cos2phi = Math.cos(2.0 * phi_rad)
        9.80616 * (1.0 - 0.0026373 * cos2phi + 0.0000059 * cos2phi * cos2phi)
      end

      # Eq. 13 — Nominal earth radius at the given latitude.
      # @return [Float] r_phi in metres
      def nominal_earth_radius
        phi_rad = @latitude_deg * Math::PI / 180.0
        cos2phi = Math.cos(2.0 * phi_rad)
        g0 = gravity_at_sea_level
        g0 * 2.0 / (3.085462e-6 + 2.27e-9 * cos2phi)
      end

      # Eq. 7 — Acceleration of free fall at geometric altitude h.
      # @param h_m [Numeric] geometric altitude in metres
      # @return [Float] g_phi(h) in m/s^2
      def gravity_at_geometric(h_m)
        r = nominal_earth_radius
        ratio = r / (r + h_m)
        gravity_at_sea_level * ratio * ratio
      end

      # Eq. 8 — Geopotential altitude from geometric altitude.
      # @param h_m [Numeric] geometric altitude in metres
      # @return [Float] geopotential altitude in metres
      def geopotential_from_geometric(h_m)
        r = nominal_earth_radius
        g0 = gravity_at_sea_level
        (r * h_m / (r + h_m)) * (g0 / G_N)
      end

      # Eq. 9 — Geometric altitude from geopotential altitude.
      # @param gp_m [Numeric] geopotential altitude in metres
      # @return [Float] geometric altitude in metres
      def geometric_from_geopotential(gp_m)
        r = nominal_earth_radius
        g0 = gravity_at_sea_level
        (r * gp_m) / ((g0 / G_N) * r - gp_m)
      end
    end
  end
end
