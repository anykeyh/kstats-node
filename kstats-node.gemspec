# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kstats/node/version'

Gem::Specification.new do |spec|
  spec.name          = "kstats-node"
  spec.version       = Kstats::Node::VERSION
  spec.authors       = ["Yacine Petitprez"]
  spec.email         = ["yacine@kosmogo.com"]
  spec.summary       = %q{Node for the project kstats}
  spec.description   = %q{Provide a simple way to make probe on system values, and monitorign theses values.}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.executables << 'kstats-node'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "sqlite3"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
