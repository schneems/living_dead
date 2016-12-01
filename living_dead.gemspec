# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'living_dead/version'

Gem::Specification.new do |spec|
  spec.name          = "living_dead"
  spec.version       = LivingDead::VERSION
  spec.authors       = ["Richard Schneeman"]
  spec.email         = ["richard.schneeman+rubygems@gmail.com"]
  spec.summary       = %q{LivingDead traces objects to see if they are retained or freed by MRI}
  spec.description   = %q{LivingDead traces objects to see if they are retained or freed by MRI}
  spec.homepage      = "https://github.com/schneems/living_dead"
  spec.license       = "MIT"

  spec.extensions    = %w[ext/living_dead/extconf.rb]
  spec.required_ruby_version = '>= 2.1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec"
end
