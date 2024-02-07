# frozen_string_literal: true
require 'yaml'

RSpec.describe Atmospheric::Isa do
  MAPPING_VAR_TO_METHOD_NAME = {
  # method name, digits to round
    H: nil,
    h: ["geometric_altitude_from_geopotential", 0],
    TK: ["temperature_at_layer_from_H", 3],
    TC: ["temperature_at_layer_celcius", 3],
    p_mbar: ["pressure_from_H_mbar", 2],
    p_mmhg: ["pressure_from_H_mmhg", 3],
    rho: ["density_from_H", 5],
    g: ["gravity_at_geopotential", 4],
    p_p_n: ["p_p_n_from_H", 5],
    rho_rho_n: ["rho_rho_n_from_H", 5],
    root_rho_rho_n: ["root_rho_rho_n_from_H", 5],
    a: ["speed_of_sound_from_H", 3],
    mu: ["dynamic_viscosity_from_H", 9],
    v: ["kinematic_viscosity_from_H", 9],
    lambda: ["thermal_conductivity_from_H", 6],
    H_p: ["pressure_scale_height_from_H", 1],
    gamma: ["specific_weight_from_H", 3],
    n: ["air_number_density_from_H", -21],
    v_bar: ["mean_air_particle_speed_from_H", 2],
    omega: ["air_particle_collision_frequency_from_H", -5],
    l: ["mean_free_path_of_air_particles_from_H", 12]
  }

  let(:isa) { Atmospheric::Isa }

  TEST_VALUES = YAML.load(IO.read('spec/fixtures/tests.yml'))
  TEST_VALUES.each_with_index do |hash, index|
    geopotential_h = hash["H"]

    MAPPING_VAR_TO_METHOD_NAME.each_pair do |var, method|
      next if method.nil?

      it "conforms to test values at H(#{hash["H"]}), variable (#{var})" do
        method_name = method[0]
        method_round = method[1]

        expected_value = hash[var.to_s]
        calc = isa.send(method_name, geopotential_h).round(method_round)

        # For variable :n, the calculated value is an integer, but the tests
        # have it as a float, so we need to convert the calculated value to
        # float
        calc = calc.to_f if var == :n

        expect(calc).to eq(expected_value)
      end
    end

  end

end
