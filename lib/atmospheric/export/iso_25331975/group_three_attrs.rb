require 'lutaml/model'

module Atmospheric
  module Export
    module Iso25331975
      class GroupThreeAttrs < Lutaml::Model::Serializable
        attribute :geometrical_altitude, :integer
        attribute :pressure_scale_height, :decimal
        attribute :specific_weight, :decimal
        attribute :air_number_density, :decimal
        attribute :mean_speed, :float
        attribute :frequency, :decimal
        attribute :mean_free_path, :decimal

        yaml do
          map "geometrical-altitude", to: :geometrical_altitude
          map "pressure-scale-height", to: :pressure_scale_height
          map "specific-weight", to: :specific_weight
          map "air-number-density", to: :air_number_density
          map "mean-speed", to: :mean_speed
          map "frequency", to: :frequency
          map "mean-free-path", to: :mean_free_path
        end
      end
    end
  end
end
