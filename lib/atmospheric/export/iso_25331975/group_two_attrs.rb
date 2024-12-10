require 'lutaml/model'

module Atmospheric
  module Export
    module Iso25331975
      class GroupTwoAttrs < Lutaml::Model::Serializable
        attribute :geometrical_altitude, :integer
        attribute :ppn, :decimal
        attribute :rhorhon, :decimal
        attribute :sqrt_rhorhon, :decimal
        attribute :speed_of_sound, :integer
        attribute :dynamic_viscosity, :decimal
        attribute :kinematic_viscosity, :decimal
        attribute :thermal_conductivity, :decimal

        yaml do
          map "geometrical-altitude", to: :geometrical_altitude
          map "ppn", to: :ppn
          map "rhorhon", to: :rhorhon
          map "sqrt-rhorhon", to: :sqrt_rhorhon
          map "speed-of-sound", to: :speed_of_sound
          map "dynamic-viscosity", to: :dynamic_viscosity
          map "kinematic-viscosity", to: :kinematic_viscosity
          map "thermal-conductivity", to: :thermal_conductivity
        end
      end
    end
  end
end
