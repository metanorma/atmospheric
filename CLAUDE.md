# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Atmospheris is a Ruby gem implementing the ISO Standard Atmosphere (ISA) model as defined in ISO 2533 and ICAO 7488/3. It serves as the reference implementation for ISO 2533:2025, providing calculations for atmospheric properties at different altitudes and generating data tables for the full ISO 2533 series.

## Development Commands

```bash
# Run all tests and linting (default rake task)
bundle exec rake

# Run specific test file
bundle exec rspec spec/atmospheris/isa_spec.rb

# Run a single test by line number
bundle exec rspec spec/atmospheris/isa_spec.rb:42

# Run only tests
bundle exec rake spec

# Run only linting
bundle exec rake rubocop

# Install dependencies
bundle install

# Generate ISO 2533 fixture tables (YAML files in spec/fixtures/)
bundle exec rake generate

# Clean generated fixtures and regenerate
bundle exec rake clean generate
```

## Architecture

### Core Components

**`Atmospheris::Isa::Algorithms`** (`lib/atmospheris/isa.rb`)
- Core calculation engine implementing ISO 2533 formulas
- Two precision modes: `:normal` (Float) and `:high` (BigDecimal)
- Access via singleton classes: `Isa::NormalPrecision.instance` or `Isa::HighPrecision.instance`
- All calculations take geopotential altitude in meters as input

**`Atmospheris::Export::*`** (`lib/atmospheris/export/`)
- Public API for generating atmospheric attributes and ISO tables
- Models use `lutaml-model` for YAML/XML serialization with UnitsML units
- Values wrapped in `UnitValueFloat` or `UnitValueInteger` with units metadata

### Key Export Classes

- **`AltitudeAttrs`**: Get atmospheric properties at a given altitude (meters/feet, geometric/geopotential)
- **`PressureAttrs`**: Get altitude from a given pressure (mbar/mmHg)
- **`Iso25331975`**, **`Iso25331985`**, **`Iso25331997`**, **`Iso25332025`**: Generate tables for respective ISO editions

### Precision Modes

Three precision modes for calculations:
- `:reduced` - Uses normal precision with significant digit rounding per ISO spec (default for tables)
- `:normal` - Uses normal precision without rounding
- `:high` - Uses BigDecimal for maximum precision

## Important Patterns

- Temperature layers defined in `Isa::Algorithms::TEMPERATURE_LAYERS` with geopotential altitude (H), temperature (T), and gradient (B)
- Pressure calculations use different formulas based on whether temperature gradient (beta) is zero
- Altitude conversions: geopotential ↔ geometric use Earth radius constant (6,356,766 m)
- Ruby's `step` method has floating-point precision issues; workaround uses `.round(n)` in `Iso25332025::HypsometricalMbar`
