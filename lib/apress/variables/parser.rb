# coding: utf-8
module Apress
  module Variables

    # Класс - парсер, реализует поиск, вычисление и замену переменных в тексте.
    # Яляется интерфейсом для работы с данным набором классов.
    #
    # Examples
    #
    #   Apress::Variables::Parser.replace_variables(:template => 'text {company_id) text',
    #                                              :object => 1234124,
    #                                              :view_context => self)
    #   => 'text 1234124 text'
    class Parser

      # Public: Заменяет переменные в шаблоне подсказки на соответствующие значения.
      #
      # params - Hash параметров:
      #          :template - String, шаблон для замены.
      #          :object  - Any Type, объект для которого расчитываются переменные.
      #          :view_context - View.
      #
      # * Заменяет переменные вида {variable(params)}, параметров может не быть.
      #
      # Returns String.

      def self.replace_variables(params)
        return if params[:template].nil?
        variables_list = list_class
        params[:template].gsub(/(\{(.+?)(\((.+?)\))?\})/) do
          if (var = variables_list.find_by_id($2)).present?
            args = $4.to_s.split(',').map(&:strip)
            params.except!(:template)
            params.merge!(:args => args)
            var.value(params)
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