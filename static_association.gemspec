lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "static_association/version"

Gem::Specification.new do |spec|
  spec.name = "static_association"
  spec.version = StaticAssociation::VERSION
  spec.authors = ["Oliver Nightingale"]
  spec.email = ["oliver.nightingale1@gmail.com"]
  spec.description = "StaticAssociation adds a simple enum type that can act like an ActiveRecord association for static data."
  spec.summary = "ActiveRecord like associations for static data"
  spec.license = "MIT"
  spec.homepage = "https://github.com/thoughtbot/static_association"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 7.1.0"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "standard"
end
