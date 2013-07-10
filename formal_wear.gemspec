# -*- encoding: utf-8 -*-
require File.expand_path('../lib/formal_wear/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jake Stetser"]
  gem.email         = ["jake@wideopenspac.es"]
  gem.description   = %q{FormalWear helps you create Form Objects with required and optional attributes and gets all fancy widdit.}
  gem.summary       = %q{You're going to like the way you look. I guarantee it.}
  gem.homepage      = "https://github.com/wideopenspaces/formal_wear"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "formal_wear"
  gem.require_paths = ["lib"]
  gem.version       = FormalWear::VERSION

  gem.add_dependency 'activesupport', '>= 3.0.20'
  gem.add_dependency 'i18n', '~> 0.5.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mocha', '~> 0.13.1'
  gem.add_development_dependency 'coveralls'
end
