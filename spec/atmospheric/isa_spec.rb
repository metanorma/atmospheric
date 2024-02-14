# frozen_string_literal: true

require "yaml"

RSpec.describe Atmospheric::Isa do
  mapping_var_to_method_name = {
    # method name, decimal places or nil, significant digits or nil
    H: nil,
    h: ["geometric_altitude_from_geopotential", 0, nil],
    TK: ["temperature_at_layer_from_geopotential", 3, nil],
    TC: ["temperature_at_layer_celcius", 3, nil],
    p_mbar: ["pressure_from_geopotential_mbar", nil, 6],
    p_mmhg: ["pressure_from_geopotential_mmhg", nil, 6],
    rho: ["density_from_geopotential", nil, 6],
    g: ["gravity_at_geopotential", 4, nil],
    p_p_n: ["p_p_n_from_geopotential", nil, 6],
    rho_rho_n: ["rho_rho_n_from_geopotential", nil, 6],
    root_rho_rho_n: ["root_rho_rho_n_from_geopotential", nil, 6],
    a: ["speed_of_sound_from_geopotential", 3, nil],
    mu: ["dynamic_viscosity_from_geopotential", nil, 5],
    v: ["kinematic_viscosity_from_geopotential", nil, 5],
    lambda: ["thermal_conductivity_from_geopotential", nil, 5],
    H_p: ["pressure_scale_height_from_geopotential", 1, nil],
    gamma: ["specific_weight_from_geopotential", nil, 5],
    n: ["air_number_density_from_geopotential", nil, 5],
    v_bar: ["mean_air_particle_speed_from_geopotential", 2, nil],
    omega: ["air_particle_collision_frequency_from_geopotential", nil, 5],
    l: ["mean_free_path_of_air_particles_from_geopotential", nil, 5],
  }.freeze

  let(:isa) { Atmospheric::Isa }

  test_values = YAML.safe_load(IO.read("spec/fixtures/tests-geopotential.yml"))
  mapping_var_to_method_name.each_pair do |var, method|
    next if method.nil?

    method_name = method[0]
    decimal_places = method[1]
    significant_digits = method[2]

    context "variable (#{var}) outputs conform to test values" do
      test_values.each do |hash|

        it "variable (#{var}) @#{hash["H"]} outputs conforms to test value" do
          geopotential_h = BigDecimal(hash["H"].to_s)
          expected_value = BigDecimal(hash[var.to_s].to_s)
          calc = isa.send(method_name, geopotential_h)
          calc = calc.round(decimal_places) if !decimal_places.nil?
          if !significant_digits.nil? && calc != 0
            calc = calc.round(significant_digits - Math.log10(calc).ceil)
          end

          # For variable :n, the calculated value is an integer, but the tests
          # have it as a float, so we need to convert the calculated value to
          # float
          calc = calc.to_f if var == :n

          expect(calc).to eq(expected_value)
        end
      end
    end
  end
end
