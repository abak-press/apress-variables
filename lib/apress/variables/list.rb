# coding: utf-8
module Apress
  module Variables

    # Набор классов предназначенных для реализации возможности
    # создания списка переменных, их поиска в тексте, вычисления и замены.
    # Состоит из классов:
    #   Variable - представляет переменную.
    #   VariablesList - список переменных.
    #   List - контейнер списка переменных.
    #   Parser - класс осуществляющий поиск, вычисление  и замену переменных.

    # Public: Представляет контейнер переменных.
    # Должен быть реализован в наследнике.
    class List
      class << self
        # Public: Возвращает список всех переменных.
        #
        # Returns variables_list_class instance.

        def all
          variables_list_class.new(list.values)
        end

        # Public: Ищет переменную в списке по идентификатору.
        #
        # id - Symblol - идентификатор переменной для поиска.
        #
        # Returns variable_class instance.

        def find_by_id(id)
          list[id.to_s]
        end

        protected

        # Protected: Возвращает класс представляющий переменную.
        # Для перекрытия в наследнике.
        #
        # Returns variable_class.

        def variable_class
          Variable
        end

        # Protected: Возвращает класс список переменных.
        # Для перекрытия в наследнике.
        #
        # Returns variables_list_class.

        def variables_list_class
          VariablesList
        end

        # Protected: Возвращает массив конкретных переменных.
        # Должен быть реализован в наследнике.
        #
        # Examples
        #
        #   def self.variables_list
        #     [
        #        {
        #            :id            => :company_id,
        #            :desc          => 'ID компании',
        #            :classes       => [ClassA, ClassB],
        #            :source_proc   => lambda { |view_context, company, params| (company.is_a?(Numeric) ? company : company.id).to_s }
        #        }
        #     ]
        #   end
        # Returns Array of Hash.

        def variables_list
          raise NotImplementedError
        end

        private

        # Private: Формирует и возвращает список переменных.
        #
        # Returns Hash, вида: id => variable.

        def list
          return @list if @list.present?
          var_class = variable_class
          var_list = variables_list.each_with_index.map { |v, index| var_class.new(v.merge(:oid => index)) }
          @list = var_list.inject(Hash.new) { |result, v| result.merge!(v[:id] => v) }
        end
      end
    end

  end
end