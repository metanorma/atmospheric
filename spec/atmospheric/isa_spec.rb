# frozen_string_literal: true

require "yaml"

RSpec.describe Atmospheric::Isa do
  mapping_var_to_method_name = {
    # method name, digits to round
    H: nil,
    h: ["geometric_altitude_from_geopotential", 0],
    TK: ["temperature_at_layer_from_geopotential", 3],
    TC: ["temperature_at_layer_celcius", 3],
    p_mbar: ["pressure_from_geopotential_mbar", 2],
    p_mmhg: ["pressure_from_geopotential_mmhg", 3],
    rho: ["density_from_geopotential", 5],
    g: ["gravity_at_geopotential", 4],
    p_p_n: ["p_p_n_from_geopotential", 5],
    rho_rho_n: ["rho_rho_n_from_geopotential", 5],
    root_rho_rho_n: ["root_rho_rho_n_from_geopotential", 5],
    a: ["speed_of_sound_from_geopotential", 3],
    mu: ["dynamic_viscosity_from_geopotential", 9],
    v: ["kinematic_viscosity_from_geopotential", 9],
    lambda: ["thermal_conductivity_from_geopotential", 6],
    H_p: ["pressure_scale_height_from_geopotential", 1],
    gamma: ["specific_weight_from_geopotential", 3],
    n: ["air_number_density_from_geopotential", -21],
    v_bar: ["mean_air_particle_speed_from_geopotential", 2],
    omega: ["air_particle_collision_frequency_from_geopotential", -5],
    l: ["mean_free_path_of_air_particles_from_geopotential", 12],
  }.freeze

  let(:isa) { Atmospheric::Isa }

  test_values = YAML.safe_load(IO.read("spec/fixtures/tests.yml"))
  test_values.each do |hash|
    geopotential_h = hash["H"]

    mapping_var_to_method_name.each_pair do |var, method|
      next if method.nil?

      it "conforms to test values at H(#{hash['H']}), variable (#{var})" do
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
