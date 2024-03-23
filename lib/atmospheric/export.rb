require "yaml"

module Atmospheric
  module Export
    class << self
      private

      def dict_to_yaml(dict, filename)
        File.write(filename, dict.to_yaml(indentation: 4)
          .gsub("\n-   ", "\n\n  - ").gsub(/^(.*):\n/, "\n\\1:")) # Make fancy
      end

      def round_to_sig_figs(num, num_sig_figs)
        num.round(num_sig_figs - Math.log10(num).ceil).to_f
      end

      public

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def iso_2533_1975_table5_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-2000..80000).step(50) do |h|
          # Step 100 above 32k, 200 above 51k
          next if (h > 32000 && h % 100 != 0) \
            || (h > 51000 && h % 200 != 0)

          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "geopotential-altitude" => h2.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(h2) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(h2) * 1000.0).round,
            "p-mbar" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(h2), 6),
            "p-mmHg" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mmhg(h2), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(h2), 6),
            "acceleration" => Isa.gravity_at_geometric(hf).round(4),
          }

          h2 = Isa.geometric_altitude_from_geopotential(hf)
          d["rows-H"] << {
            "geopotential-altitude" => h,
            "geometrical-altitude" => h2.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(hf) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(hf) * 1000.0).round,
            "p-mbar" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(hf), 6),
            "p-mmHg" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mmhg(hf), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(hf), 6),
            "acceleration" => Isa.gravity_at_geopotential(hf).round(4),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_1975_table6_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-2000..80000).step(50) do |h|
          # Step 100 above 32k, 200 above 51k
          next if (h > 32000 && h % 100 != 0) \
            || (h > 51000 && h % 200 != 0)

          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(h2), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(h2), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(h2), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(h2) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(h2), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(h2), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(hf), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(hf), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(hf), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(hf) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(hf), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(hf), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(hf), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_1975_table7_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-2000..80000).step(50) do |h|
          # Step 100 above 32k, 200 above 51k
          next if (h > 32000 && h % 100 != 0) \
            || (h > 51000 && h % 200 != 0)

          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(h2).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(h2), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(h2), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(h2).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(h2), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(hf).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(hf), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(hf), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(hf).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(hf), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(hf), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table1_to_yaml(filename)
        d = { "rows" => [] }

        (5.0..19.99).step(0.01) do |p|
          d["rows"] << {
            "pressure" => p.round(2),
            "geopotential-altitude" =>
              Isa.geopotential_altitude_from_pressure_mbar(p.round(2)).round,
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table2_to_yaml(filename)
        d = { "rows" => [] }

        (20.0..1199.9).step(0.1) do |p|
          d["rows"] << {
            "pressure" => p.round(1),
            "geopotential-altitude" =>
              Isa.geopotential_altitude_from_pressure_mbar(p.round(1)).round,
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table3_to_yaml(filename)
        d = { "rows" => [] }

        (4.0..9.99).step(0.01) do |p|
          d["rows"] << {
            "pressure" => p.round(2),
            "geopotential-altitude" =>
              Isa.geopotential_altitude_from_pressure_mmhg(p.round(2)).round,
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table4_to_yaml(filename)
        d = { "rows" => [] }

        (10.0..899.9).step(0.1) do |p|
          d["rows"] << {
            "pressure" => p.round(1),
            "geopotential-altitude" =>
              Isa.geopotential_altitude_from_pressure_mmhg(p.round(1)).round,
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table5_to_yaml(filename)
        d = { "rows" => [] }

        (-1000..4599).step(1) do |h|
          d["rows"] << {
            "geopotential-altitude" => h,
            "pressure" =>
              round_to_sig_figs(
                Isa.pressure_from_geopotential_mbar(h.to_f), 6
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_1_1985_table6_to_yaml(filename)
        d = { "rows" => [] }

        (-1000..4599).step(1) do |h|
          d["rows"] << {
            "geopotential-altitude" => h,
            "pressure" =>
              round_to_sig_figs(
                Isa.pressure_from_geopotential_mmhg(h.to_f), 6
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table1_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-5000..2000).step(50) do |h|
          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "geopotential-altitude" => h2.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(h2) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(h2) * 1000.0).round,
            "pressure" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(h2), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(h2), 6),
            "acceleration" => Isa.gravity_at_geometric(hf).round(4),
          }

          h2 = Isa.geometric_altitude_from_geopotential(hf)
          d["rows-H"] << {
            "geopotential-altitude" => h,
            "geometrical-altitude" => h2.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(hf) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(hf) * 1000.0).round,
            "pressure" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(hf), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(hf), 6),
            "acceleration" => Isa.gravity_at_geopotential(hf).round(4),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table2_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-5000..2000).step(50) do |h|
          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(h2), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(h2), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(h2), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(h2) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(h2), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(h2), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(hf), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(hf), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(hf), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(hf) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(hf), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(hf), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(hf), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table3_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-5000..2000).step(50) do |h|
          hf = h.to_f
          h2 = Isa.geopotential_altitude_from_geometric(hf)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(h2).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(h2), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(h2), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(h2).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(h2), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(hf).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(hf), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(hf), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(hf).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(hf), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(hf), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table4_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-16500..262500).step(50) do |h|
          # Step 250 until -14k, then 200 until 105k, then 500
          next if (h <= -14000 && h % 250 != 0) \
            || (h > -14000 && h <= 105000 && h % 200 != 0) \
            || (h > 105000 && h % 500 != 0)

          hf = h.to_f
          hm = hf * 0.3048
          h2 = Isa.geopotential_altitude_from_geometric(hm)
          h2ft = h2 / 0.3048
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "geopotential-altitude" => h2ft.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(h2) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(h2) * 1000.0).round,
            "pressure" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(h2), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(h2), 6),
            "acceleration" => Isa.gravity_at_geometric(hf).round(4),
          }

          h2 = Isa.geometric_altitude_from_geopotential(hm)
          h2ft = h2 / 0.3048
          d["rows-H"] << {
            "geopotential-altitude" => h,
            "geometrical-altitude" => h2ft.round,
            "temperature-K" =>
              (Isa.temperature_at_layer_from_geopotential(hm) * 1000.0).round,
            "temperature-C" =>
              (Isa.temperature_at_layer_celcius(hm) * 1000.0).round,
            "pressure" =>
              round_to_sig_figs(Isa.pressure_from_geopotential_mbar(hm), 6),
            "density" =>
              round_to_sig_figs(Isa.density_from_geopotential(hm), 6),
            "acceleration" => Isa.gravity_at_geopotential(hm).round(4),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table5_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-16500..262500).step(50) do |h|
          # Step 250 until -14k, then 200 until 105k, then 500
          next if (h <= -14000 && h % 250 != 0) \
            || (h > -14000 && h <= 105000 && h % 200 != 0) \
            || (h > 105000 && h % 500 != 0)

          hf = h.to_f
          hm = hf * 0.3048
          h2 = Isa.geopotential_altitude_from_geometric(hm)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(h2), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(h2), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(h2), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(h2) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(h2), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(h2), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "ppn" => round_to_sig_figs(Isa.p_p_n_from_geopotential(hm), 6),
            "rhorhon" =>
              round_to_sig_figs(Isa.rho_rho_n_from_geopotential(hm), 6),
            "sqrt-rhorhon" =>
              round_to_sig_figs(Isa.root_rho_rho_n_from_geopotential(hm), 6),
            "speed-of-sound" =>
              (Isa.speed_of_sound_from_geopotential(hm) * 1000.0).round,
            "dynamic-viscosity" =>
              round_to_sig_figs(
                Isa.dynamic_viscosity_from_geopotential(hm), 5
              ),
            "kinematic-viscosity" =>
              round_to_sig_figs(
                Isa.kinematic_viscosity_from_geopotential(hm), 5
              ),
            "thermal-conductivity" =>
              round_to_sig_figs(
                Isa.thermal_conductivity_from_geopotential(hm), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end

      def iso_2533_add_2_1997_table6_to_yaml(filename)
        d = { "rows-h" => [], "rows-H" => [] }

        (-16500..262500).step(50) do |h|
          # Step 250 until -14k, then 200 until 105k, then 500
          next if (h <= -14000 && h % 250 != 0) \
            || (h > -14000 && h <= 105000 && h % 200 != 0) \
            || (h > 105000 && h % 500 != 0)

          hf = h.to_f
          hm = hf * 0.3048
          h2 = Isa.geopotential_altitude_from_geometric(hm)
          d["rows-h"] << {
            "geometrical-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(h2).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(h2), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(h2), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(h2).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(h2), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(h2), 5
              ),
          }

          d["rows-H"] << {
            "geopotential-altitude" => h,
            "pressure-scale-height" =>
              Isa.pressure_scale_height_from_geopotential(hm).round(1),
            "specific-weight" =>
              round_to_sig_figs(Isa.specific_weight_from_geopotential(hm), 5),
            "air-number-density" =>
              round_to_sig_figs(
                Isa.air_number_density_from_geopotential(hm), 5
              ),
            "mean-speed" =>
              Isa.mean_air_particle_speed_from_geopotential(hm).round(2),
            "frequency" =>
              round_to_sig_figs(
                Isa.air_particle_collision_frequency_from_geopotential(hm), 5
              ),
            "mean-free-path" =>
              round_to_sig_figs(
                Isa.mean_free_path_of_air_particles_from_geopotential(hm), 5
              ),
          }
        end
        dict_to_yaml(d, filename)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
