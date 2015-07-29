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

      def initialize(variables_list)
        @variables_list = variables_list
      end

      # Public: Заменяет переменные в шаблоне подсказки на соответствующие значения.
      #
      # template - String, шаблон для замены.
      # params   - Hash, хеш параметров необходимых для расчета переменных.
      #
      # * Заменяет переменные вида {variable(args)}, аргументов может не быть.
      #
      # Returns String.
      #
      def replace_variables(template, params)
        return if template.nil?
        template.gsub(/(\{(.+?)(\((.+?)\))?\})/) do
          if (var = variables_list.find_by_id($2)).present?
            args = $4.to_s.split(',').map(&:strip)
            var.value(params, args)
          else
            $1
          end
        end.try(:html_safe)
      end
    end
  end
end