# coding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'resonad/version'

Gem::Specification.new do |spec|
  spec.name          = 'resonad'
  spec.version       = Resonad::VERSION
  spec.authors       = ["Tom Dalling"]
  spec.email         = ['tom' + '@' + 'tomdalling.com']

  spec.summary       = "Objects that represent success or failure"
  spec.description   = "Objects that represent success or failure"
  spec.homepage      = "https://github.com/tomdalling/resonad"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "gem-release", "~> 2.1"
  spec.add_development_dependency "byebug"
end
