# -*- encoding: utf-8 -*-
require File.expand_path('../lib/formal_wear/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jake Stetser"]
  gem.email         = ["jake@wideopenspac.es"]
  gem.description   = %q{FormalWear helps you create Form Objects with required and optional attributes and gets all fancy widdit.}
  gem.summary       = %q{EZ Form objects}
  gem.homepage      = "https://github.com/wideopenspaces/formal_wear"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "formal_wear"
  gem.require_paths = ["lib"]
  gem.version       = FormalWear::VERSION

  gem.add_dependency 'activesupport', '>= 3.0.20'
  gem.add_dependency 'hash_assertions', '~> 0.1.0'
  gem.add_development_dependency 'rspec'
end
