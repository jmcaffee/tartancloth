# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tartancloth'

Gem::Specification.new do |spec|
  spec.name          = "tartancloth"
  spec.version       = TartanCloth::VERSION
  spec.authors       = ["Jeff McAffee"]
  spec.email         = ["jeff@ktechsystems.com"]
  spec.description   = %q{A wrapper around the BlueCloth gem which incorporates HTML5 headers, footers, and a table of contents all with a nice stylesheet.}
  spec.summary       = %q{Generate nice HTML with a table of contents}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'bluecloth', '~> 2.2', '>= 2.2.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.5', '>= 1.5.6'
end
