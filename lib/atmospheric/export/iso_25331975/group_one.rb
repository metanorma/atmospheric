require_relative "./group_base"
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Layout/LineLength
# rubocop:disable Layout/HashAlignment
module Atmospheric
  module Export
    module Iso25331975

      class GroupOne < GroupBase
        # In meters only
        def row_from_geopotential(gp_h_f)
          {
            "temperature-K" => (Isa.temperature_at_layer_from_geopotential(gp_h_f) * 1000.0).round,
            "temperature-C" => (Isa.temperature_at_layer_celcius(gp_h_f) * 1000.0).round,
            "pressure-mbar" => round_to_sig_figs(Isa.pressure_from_geopotential_mbar(gp_h_f), 6),
            "pressure-mmHg" => round_to_sig_figs(Isa.pressure_from_geopotential_mmhg(gp_h_f), 6),
            "density"       => round_to_sig_figs(Isa.density_from_geopotential(gp_h_f), 6),
            "acceleration"  => Isa.gravity_at_geopotential(gp_h_f).round(4),
          }
        end
      end
    end

  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Layout/LineLength
# rubocop:enable Layout/HashAlignment
