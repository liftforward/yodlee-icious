# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yodleeicious/version'

Gem::Specification.new do |spec|
  spec.name          = "yodlee-icious"
  spec.version       = Yodleeicious::VERSION
  spec.authors       = ["Drew Nichols"]
  spec.email         = ["drew@liftforward.com"]
  spec.summary       = "Yodlee API Client Gem"
  spec.description   = "Delicious Yodlee API Client Gem (formally Yodlicious)"
  spec.homepage      = "https://github.com/liftforward/yodlee-icious"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "faraday",            "~> 0.9"
  spec.add_runtime_dependency "faraday_middleware", "~> 0.10"
  spec.add_runtime_dependency "socksify",           "~> 1.7"

  spec.required_ruby_version = '>= 1.9.3'
end
