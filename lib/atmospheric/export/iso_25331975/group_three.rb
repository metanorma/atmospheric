require_relative "./group_base"
require_relative "group_three_attrs"
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
      class GroupThree < GroupBase
        attribute :id, :string
        attribute :title_en, :string
        attribute :title_fr, :string
        attribute :title_ru, :string
        attribute :note_en, :string
        attribute :note_fr, :string

        attribute :by_geometrical_altitude, GroupThreeAttrs, collection: true
        attribute :by_geopotential_altitude, GroupThreeAttrs, collection: true

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
            "pressure-scale-height" => Isa.pressure_scale_height_from_geopotential(gp_h_f).round(1),
            "specific-weight"       => round_to_sig_figs(Isa.specific_weight_from_geopotential(gp_h_f), 5),
            "air-number-density"    => round_to_sig_figs(Isa.air_number_density_from_geopotential(gp_h_f), 5),
            "mean-speed"            => Isa.mean_air_particle_speed_from_geopotential(gp_h_f).round(2),
            "frequency"             => round_to_sig_figs(Isa.air_particle_collision_frequency_from_geopotential(gp_h_f), 5),
            "mean-free-path"        => round_to_sig_figs(Isa.mean_free_path_of_air_particles_from_geopotential(gp_h_f), 5),
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
