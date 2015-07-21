# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'once/version'

Gem::Specification.new do |spec|
  spec.name          = "once"
  spec.version       = Once::VERSION
  spec.authors       = ["Yan Pritzker"]
  spec.email         = ["yan@reverb.com"]
  spec.description   = %q{Uses Redis to guarantee uniqueness for executing a particular command}
  spec.summary       = %q{Execute commands only once within a specified period of time}
  spec.homepage      = "https://github.com/reverbdotcom/once"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "timecop"
end
