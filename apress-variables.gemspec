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

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activesupport', '>= 3.1.0', '< 4.1.0'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  # test coverage tool
  gem.add_development_dependency 'simplecov'

  # code quality check
  gem.add_development_dependency 'cane', '>= 2.6.0'

  # dependencies security tool
  gem.add_development_dependency 'bundler-audit'

  # automatic changelog builder
  gem.add_development_dependency 'changelogger'

  # a tool for uploading files to private gem repo
  gem.add_development_dependency 'multipart-post'
end