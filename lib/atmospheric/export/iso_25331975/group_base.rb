require_relative "../target"

module Atmospheric
  module Export
    module Iso25331975
      class GroupBase
        include Target

        def row_big_h(h, unit: :meters)
          hgpm, hgpf = values_in_m_ft(h, unit: unit)
          hgmm = Isa.geometric_altitude_from_geopotential(hgpm)
          hgmf = m_to_ft(hgmm).round
          height_hash(hgmm, hgmf, hgpm, hgpf)
            .merge(self.row_from_geopotential(hgpm))
        end

        def row_small_h(h, unit: :meters)
          hgmm, hgmf = values_in_m_ft(h, unit: unit)
          hgpm = Isa.geopotential_altitude_from_geometric(hgmm)
          hgpf = m_to_ft(hgpm).round
          height_hash(hgmm, hgmf, hgpm, hgpf)
            .merge(self.row_from_geopotential(hgpm))
        end

        def height_hash(hgmm, hgmf, hgpm, hgpf)
          {
            "geopotential-altitude-m"  => hgmm.round,
            "geopotential-altitude-ft" => hgmf.round,
            "geometrical-altitude-m"   => hgpm.round,
            "geometrical-altitude-ft"  => hgpf.round,
          }
        end

        def values_in_m_ft(value, unit: :meters)
          case unit
          when :meters
            [value.to_f, m_to_ft(value)]
          when :feet
            [ft_to_m(value), value.to_f]
          end
        end

        # Step 50 from -2k to 40k, step 100 above 32k, 200 above 51k to 80k
        def steps
          (
            (-2000..31999).step(50) +
            (32000..50999).step(100) +
            (51000..80000).step(200)
          )
        end

        def steps_unit
          :meters
        end

        def to_h(unit: steps_unit)
          d = {
            "by-geometrical-altitude" => [],
            "by-geopotential-altitude" => []
          }

          steps.each do |h|
            d["by-geometrical-altitude"] << row_small_h(h, unit: unit)
            d["by-geopotential-altitude"] << row_big_h(h, unit: unit)
          end
          d
        end
      end

    end
  end
end
