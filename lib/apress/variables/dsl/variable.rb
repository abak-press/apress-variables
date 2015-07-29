# coding: utf-8
require 'active_support/concern'
require_relative 'base'

module Apress
  module Variables
    module Dsl
      module Variable
        extend ActiveSupport::Concern

        class Configuration < ::Apress::Variables::Dsl::Base
          alias_method :variable, :target

          setter :id
          setter :name
          setter :desc
          setter :type
          setter :default
          setter :rate
          setter :max_rate
          setter :options

          setter :source_class
          setter :source_params
          setter :source_proc

          varags_setter :context
          varags_setter :groups
          varags_setter :classes
        end

        module ClassMethods
          def build(context, &block)
            variable = new
            variable.context = context

            Configuration.new(variable, &block)
            variable
          end
        end
      end
    end
  end
end