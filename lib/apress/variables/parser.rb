# coding: utf-8
module Apress
  module Variables

    # Класс - парсер, реализует поиск, вычисление и замену переменных в тексте.
    # Яляется интерфейсом для работы с данным набором классов.
    #
    # Examples
    #
    #   Apress::Variables::Parser.replace_variables('text {company_id) text', :param => 1234124)
    #   => 'text 1234124 text'
    class Parser

      # Public: Заменяет переменные в шаблоне подсказки на соответствующие значения.
      #
      # template - String, шаблон для замены.
      # params   - Hash, хеш параметров необходимых для расчета переменных.
      #
      # * Заменяет переменные вида {variable(args)}, аргументов может не быть.
      #
      # Returns String.

      def self.replace_variables(template, params)
        return if template.nil?
        variables_list = list_class
        template.gsub(/(\{(.+?)(\((.+?)\))?\})/) do
          if (var = variables_list.find_by_id($2)).present?
            args = $4.to_s.split(',').map(&:strip)
            var.value(params, args)
          else
            $1
          end
        end.try(:html_safe)
      end

      protected

      # Protected: Возвращает класс - список переменных.
      # Должен быть реализован в наследнике.
      #
      # Returns list class.

      def self.list_class
        raise NotImplementedError
      end
    end

  end
end