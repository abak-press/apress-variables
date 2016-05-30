# coding: utf-8
module Apress
  module Variables
    # Класс - парсер, реализует поиск, вычисление и замену переменных в тексте.
    #
    # Examples
    #
    #   parser = Apress::Variables::Parser.new(variables_list)
    #   parser.replace_variables('text {company_id) text', :param => 1234124)
    #   => 'text 1234124 text'
    class Parser
      attr_accessor :variables_list
      attr_accessor :options

      # Public: Конструктор.
      #
      # variables_list - Apress::Variables::List - список переменных.
      # options  - Hash, хеш опций:
      #            :silent - boolean - не генерировать исключение при неизвестной переменной
      #                                По умолчанию: true.
      # Returns Parser.
      #
      def initialize(variables_list, options = {})
        @variables_list = variables_list
        @options = options.reverse_merge!(:silent => true)
      end

      # Public: Заменяет переменные в шаблоне подсказки на соответствующие значения.
      #
      # template - String, шаблон для замены.
      # params   - Hash, хеш параметров необходимых для расчета переменных.
      #
      # Заменяет переменные вида {variable(args)}, аргументов может не быть.
      # Заменяет вложенные переменные {variable1({variable2(args)})}
      #
      # Если опция silent - false, и переменная не найденна в списке
      # или переменная генерирует Apress::Variables::UnknownVariableError,
      # выкидывается исключение UnknownVariableError
      #
      # Returns ActiveSupport::SafeBuffer.
      #
      def replace_variables(template, params)
        return ActiveSupport::SafeBuffer.new if template.nil?

        result = internal_replace(template.dup, params)

        result.try(:html_safe)
      end

      private

      def internal_replace(template, params)
        return if template.nil?

        # заменяет простые переменные, внутри переменной
        template.gsub!(/\{(?<sub_expression>[^{]+(\{[^{}]+\}[^{]+?)+)\}/) do
          "{#{replace_simple_variables($~[:sub_expression], params)}}"
        end

        replace_simple_variables(template, params)

        template
      end

      def replace_simple_variables(template, params)
        return if template.nil?

        template.gsub!(/\{(?<var>[^{}]+?)(\((?<args>[^{}]+?)\))?\}/) do |substring|
          begin
            if (var = variables_list.find_by_id($~[:var])).present?
              args = $~[:args].to_s.split(',').map(&:strip)
              var.value(params, args)
            else
              raise UnknownVariableError
            end
          rescue UnknownVariableError
            raise UnknownVariableError, "Variable #{$~[:var]} with args #{$~[:args]} not found in list" unless silent?
            substring
          end
        end
      end

      def silent?
        options.fetch(:silent)
      end
    end
  end
end
