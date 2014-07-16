# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commander/version'

Gem::Specification.new do |spec|
  spec.name          = "commander"
  spec.version       = Commander::VERSION
  spec.authors       = ["jschmid1"]
  spec.email         = ["jschmid@suse.de"]
  spec.summary       = %q{Automatically sets a Commanding officer of the Week. Every Tuesday}
  spec.description   = %q{fair}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
