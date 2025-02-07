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
        geopotential_h = hash["H"]
        expected_value = hash[var.to_s]

        it "variable (#{var}) H=#{hash["H"]} outputs conforms to test value" do
          calc = isa.send(method_name, geopotential_h)
          calc = calc.round(decimal_places) if !decimal_places.nil?

          # Some values are missing due to missing page in original
          # ISO 2533:1975 document.
          # See https://github.com/metanorma/iso-2533/issues/9
          if expected_value.nil? && var == :p_mmhg &&
             geopotential_h >= 48000.0 && geopotential_h <= 56800.0
            pending "missing value in original document (metanorma/iso-2533#9)"
          end

          expect(expected_value).to_not be_nil

          # For variable :n, the calculated value is an integer, but the tests
          # have it as a float, so we need to convert the calculated value to
          # float
          calc = calc.to_f if var == :n

          if !significant_digits.nil? && calc != 0
            calc = calc.round(significant_digits - Math.log10(calc).ceil)
            diff = 10 ** -(significant_digits - Math.log10(calc).ceil)

            expected_min = expected_value - diff
            expected_min = expected_min.round(significant_digits - Math.log10(calc).ceil)

            expected_max = expected_value + diff
            expected_max = expected_max.round(significant_digits - Math.log10(calc).ceil)
          else
            diff = 10 ** -decimal_places
            expected_min = (expected_value - diff).round(decimal_places)
            expected_max = (expected_value + diff).round(decimal_places)
          end

          expect(calc).to be_between(expected_min, expected_max)
        end
      end
    end
  end
end
