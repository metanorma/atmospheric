require_relative "./group_base"
require_relative "group_two_attrs"
require 'bigdecimal'
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
        attribute :id, :string
        attribute :title_en, :string
        attribute :title_fr, :string
        attribute :title_ru, :string
        attribute :note_en, :string
        attribute :note_fr, :string

        attribute :by_geometrical_altitude, GroupTwoAttrs, collection: true
        attribute :by_geopotential_altitude, GroupTwoAttrs, collection: true

        yaml do
          map "id", to: :id
          map "title-en", to: :title_en
          map "title-fr", to: :title_fr
          map "title-ru", to: :title_ru
          map "note-rn", to: :note_en
          map "note-fr", to: :note_fr
          map "by-geometrical-altitude", to: :by_geometrical_altitude
          map "by-geopotential-altitude", to: :by_geopotential_altitude
        end

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
