lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "atmospheric/version"

Gem::Specification.new do |spec|
  spec.name          = "atmospheric"
  spec.version       = Atmospheric::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.homepage      = "https://github.com/metanorma/atmospheric"
  spec.summary       = <<~HERE.strip
    Implementation of the ISO Standard Atmosphere (ISA) model"
  HERE
  spec.description = <<~HERE.strip
    Implementation of the ISO Standard Atmosphere (ISA) model as
    defined in ISO 2533 and ICAO 7488/3 1994.
    Reference implementation used in ISO 2533:2025."
  HERE

  spec.license = "BSD-2-Clause"

  spec.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH)
  spec.extra_rdoc_files = %w[README.adoc LICENSE.txt]
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.add_dependency "bigdecimal"
  spec.add_dependency "lutaml-model", "~> 0.7.0"
  spec.add_dependency "nokogiri"
end
