require 'rails/engine'
require 'active_support/all'
require 'apress/documentation'

require 'apress/variables/variable'
require 'apress/variables/list'
require 'apress/variables/parser'

require 'apress/variables/engine'
require 'apress/variables/version'

module Apress
  module Variables
    class Error < StandardError; end
    class UnknownVariableError < Error; end
  end
end
