# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apress/variables/version'

Gem::Specification.new do |gem|
  gem.name          = 'apress-variables'
  gem.version       = Apress::Variables::VERSION
  gem.authors       = ['Artem Napolskih']
  gem.email         = %w(napolskih@gmail.com)
  gem.summary       = %q{apress-variables}
  gem.homepage      = 'https://github.com/abak-press/apress-variables'

  gem.metadata["allowed_push_host"] = "https://gems.railsc.ru"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'railties', '>= 4.0.13', '< 5.1'
  gem.add_dependency 'activesupport', '>= 4.0.13', '< 5.1'
  gem.add_dependency 'apress-documentation', '>= 0.2.0'

  gem.add_development_dependency 'bundler', '~> 1.17.3'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'simplecov'
end
