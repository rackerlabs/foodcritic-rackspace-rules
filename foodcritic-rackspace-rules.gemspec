# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foodcritic/rackspace/rules/version'

Gem::Specification.new do |spec|
  spec.name          = "foodcritic-rackspace-rules"
  spec.version       = Foodcritic::Rackspace::Rules::VERSION
  spec.authors       = ["Martin Smith"]
  spec.email         = ["martin@mbs3.org"]
  spec.summary       = %q{Foodcritic rules for rackops cookbooks or stacks}
  spec.description   = %q{See README.md}
  spec.homepage      = "https://github.com/racker/foodcritic-rackspace-rules"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'bundler', '~> 1.6'
  spec.add_runtime_dependency 'rake', '>= 10'
  spec.add_runtime_dependency 'foodcritic', '>= 3'
end
