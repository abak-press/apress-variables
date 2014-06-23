require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'simplecov'

SimpleCov.start('test_frameworks')

require 'apress/variables'

# require helpers
support_dir = File.expand_path(File.join('..', 'support'), __FILE__)
Dir[File.join(support_dir, '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [/lib\/rspec\/(core|expectations|matchers|mocks)/]
  config.formatter = 'documentation'
  config.color = true
  config.order = 'random'
end