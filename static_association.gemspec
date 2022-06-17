# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'static_association/version'

Gem::Specification.new do |spec|
  spec.name          = "static_association"
  spec.version       = StaticAssociation::VERSION
  spec.authors       = ["Oliver Nightingale"]
  spec.email         = ["oliver.nightingale1@gmail.com"]
  spec.description   = %q{StaticAssociation adds a simple enum type that can act like an ActiveRecord association for static data.}
  spec.summary       = %q{ActiveRecord like associations for static data}
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/New-Bamboo/static_association"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.0.0"

  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "appraisal"
end
