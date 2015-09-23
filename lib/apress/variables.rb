require 'active_support/all'

require 'apress/variables/version'
require 'apress/variables/variable'
require 'apress/variables/list'
require 'apress/variables/parser'

module Apress
  module Variables
    class Error < StandardError; end
    class UnknownVariableError < Error; end
  end
end
