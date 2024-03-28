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

      class GroupTwo < GroupBase
        # In meters only
        def row_from_geopotential(gp_h_f)
          {
            "ppn"                  => round_to_sig_figs(Isa.p_p_n_from_geopotential(gp_h_f), 6),
            "rhorhon"              => round_to_sig_figs(Isa.rho_rho_n_from_geopotential(gp_h_f), 6),
            "sqrt-rhorhon"         => round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(gp_h_f), 6),
            "speed-of-sound"       => (Isa.speed_of_sound_from_geopotential(gp_h_f) * 1000.0).round,
            "dynamic-viscosity"    => round_to_sig_figs(Isa.dynamic_viscosity_from_geopotential(gp_h_f), 5),
            "kinematic-viscosity"  => round_to_sig_figs(Isa.kinematic_viscosity_from_geopotential(gp_h_f), 5),
            "thermal-conductivity" => round_to_sig_figs(Isa.thermal_conductivity_from_geopotential(gp_h_f), 5),
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
