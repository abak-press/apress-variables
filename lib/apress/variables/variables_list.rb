# coding: utf-8
module Apress
  module Variables

    # Public: Класс - список переменных.
    # Экземпляры этого класса возвращают все методы возвращающие список переменных.
    # Используйте в качестве базового класса, для расширения функциональности списка.
    class VariablesList < Array

      # Public: Возвращает список доступных переменных для класса.
      #
      # klass   - String или Class или Array - одно или несколько имен классов,
      #           фильтры для которых необходимо получить.
      #
      # Returns Apress::Filters::FiltersList - список фильтров для класса.
      #
      def for_class(klass)
        self.class.new(
          self.
          select { |i| i.for_any_class? || i.for_class?(klass) }
        )
      end

      def for_group(group)
        self.class.new(
          self.
          select { |i| i.for_any_group? || for_group?(group) }
        )
      end

      # Public: Возвращает список переменных являющихся "редиректом"
      #
      # Returns Instance of self.class.

      def redirects
        self.class.new(self.select(&:redirect?))
      end

      # Public: Возвращает список переменных не являющихся "редиректом"
      #
      # Returns Instance of self.class.

      def variables
        self.class.new(self - redirects)
      end
    end

  end
end