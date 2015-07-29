# coding: utf-8
require_relative 'dsl/list'

module Apress
  module Variables
    # Класс - список переменных.
    #
    # Хранит экземпляры классов Variable.
    # Имеет DSL для удобного создания списка переменных.
    # У каждой переменной есть конекст - набор параметров, необходимых для ее расчета.
    # В списке могут хранится переменные с разными контекстами.
    # ID переменных в разных списках могут дублироваться, но не не могут в рамках одного списка.
    # Если в список добавляются 2 переменные с одним контексом и одинаковвым ID, сохраняется последняя.
    #
    # Example:
    #
    #   List.add_variables do #
    #     variable do
    #       context     :user_id
    #       id          'user:id'
    #       desc        'ID пользователя'
    #       source_proc ->(params, args) { params.fetch(:user_id).to_s }
    #     end
    #   end
    #
    class List
      include ::Apress::Variables::Dsl::List
      include Enumerable

      def initialize(list = [])
        @storage = Hash.new
        assign(list)
      end

      def add(variable)
        key = key_for_context(variable.context)
        @storage[key] ||= HashWithIndifferentAccess.new
        @storage[key][variable.id] = variable
        self
      end

      def find_by_id(id)
        id = id.to_s
        @storage.each_value do |list|
          return list[id] if list.key?(id)
        end

        nil
      end

      def for_context(context)
        context_set = key_for_context(context)

        result = @storage.flat_map do |key, list|
          list.values if key.subset?(context_set)
        end

        self.class.new(result.compact)
      end

      def redirects
        self.class.new(select(&:redirect?))
      end

      def variables
        self.class.new(self.to_a - redirects.to_a)
      end

      def for_class(klass)
        self.class.new(select { |var| var.for_class?(klass) })
      end

      def for_group(group)
        self.class.new(select { |var| var.for_group?(group) })
      end

      def uniq_by_id
        result = each_with_object(Hash.new) do |variable, memo|
          memo[variable.id] = variable unless memo.key?(variable.id)
        end

        self.class.new(result.values)
      end

      def variable_class
        ::Apress::Variables::Variable
      end

      protected

      def assign(list)
        list.each { |variable| add(variable) }
      end

      def key_for_context(context)
        context = context.keys if context.is_a?(Hash)
        context.map { |param| param.to_s.downcase }.to_set
      end

      def each
        @storage.each_value do |list|
          list.each_value do |variable|
            yield variable
          end
        end
      end
    end

    mattr_accessor :list
    self.list = List.new

    ActiveSupport.run_load_hooks(:'apress/variables/list', List)
  end
end