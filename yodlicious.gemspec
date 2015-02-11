# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yodlicious/version'

Gem::Specification.new do |spec|
  spec.name          = "yodlicious"
  spec.version       = Yodlicious::VERSION
  spec.authors       = ["Drew Nichols"]
  spec.email         = ["drew@liftforward.com"]
  spec.summary       = "Yodlee API Client Gem"
  spec.description   = "Delicious Yodlee API Client Gem"
  spec.homepage      = "https://github.com/liftforward/yodlicious"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  
  spec.add_runtime_dependency "rest-client", "~> 1.7.2", '>= 1.7.0'

  spec.required_ruby_version = '>= 1.9.3'
end
