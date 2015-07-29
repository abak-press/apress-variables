# coding: utf-8
require_relative 'base'

module Apress
  module Variables
    module Dsl
      module List
        extend ActiveSupport::Concern

        class Configuration < ::Apress::Variables::Dsl::Base
          alias_method :list, :target

          attr_reader :current_context

          def context(*value)
            @current_context = value.flatten
          end

          def variable(&block)
            variable = list.variable_class.build(current_context, &block)
            list.add(variable)
          end
        end

        def add_variables(&block)
          Configuration.new(self, &block)
          self
        end

        module ClassMethods
          def add_variables(&block)
            new.add_variables(&block)
          end
        end
      end
    end
  end
end