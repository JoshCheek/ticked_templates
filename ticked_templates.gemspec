$LOAD_PATH.unshift File.realpath("lib", __dir__)
require "ticked/version"

Gem::Specification.new do |s|
  s.name        = "ticked"
  s.version     = Ticked::VERSION
  s.authors     = ["Josh Cheek"]
  s.email       = ["josh.cheek@gmail.com"]
  s.homepage    = "https://github.com/JoshCheek/ticked_templates"
  s.summary     = "Bringing the awesomeness of ECMAScript's tagged templates to Ruby!"
  s.description = "Bringing the awesomeness of ECMAScript's tagged templates to Ruby!"
  s.license     = "WTFPL"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "binding_of_caller", "~> 0.8.0"

  s.add_development_dependency "rspec"
end
