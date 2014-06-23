# coding: utf-8
module Apress
  module Variables

    # Public: Класс представляющий переменную.
    class Variable < Hash
      # Public: конструктор
      #
      # hash - Hash свойств переменной:
      #       :id            - Symbol - идентификатор переменной.
      #       :name          - String - название переменной (опционально).
      #       :desc          - String - описание переменной.
      #       :source_class  - String/Class - класс клсса - источника данных (опционально).
      #       :source_params - Any Type - дополнительные параметры источника (опционально).
      #       :source_proc   - Lambda/Proc - выражение для вычисления переменной (опционально).
      #       :type          - :integer - тип переменной (опционально).
      #       :default       - String - значение по умолчанию, если переменная blank? (опционально).
      #
      # Returns Variable instance.

      def initialize(hash = {})
        super(nil)
        hash.each do |key, value|
          self[key] = value
        end
      end

      # Public: Вычисляет и возвращает значение переменной.
      #
      # params - Hash параметров:
      #          :object  - Any Type, объект для которого расчитываются переменные.
      #          :view_context - View.
      #          :args - Массив параметров для вычисления переменной (опционально).
      #
      # Returns String.

      def value(params)
        params[:args] ||= []
        format(raw_value(params))
      end

      # Public: Возвращает имя переменной.
      #
      # Returns String.

      def pretty_name
        self[:name] || self[:id]
      end

      # Public: Является ли переменная "редиректом".
      #
      # Returns Boolean.

      def redirect?
        self[:id].to_s.end_with?('redirect')
      end

      def for_any_class?
        self[:classes].nil? || self[:classes] == :all
      end

      def for_any_group?
        self[:groups].nil? || self[:groups] == :all
      end

      def for_class?(klass)
        (Array(self[:classes]).map(&:to_s) & Array.wrap(klass).map(&:to_s)).present?
      end

      def for_group?(group)
        (Array(self[:groups]).map(&:to_s) & Array.wrap(group).map(&:to_s)).present?
      end

      protected

      # Protected: Форматирует значение переменной, согласно типу переменной и опциям форматирования.
      #
      # value - String - значение переменной.
      #
      # Returns String.

      def format(value)
        case self[:type]
          when :integer
            value.to_i.to_s
          else if value.blank? && self[:default]
            self[:default]
          else
            value
          end
        end
      end

      # Protected: Вычисляет значение переменной.
      #
      # params - Hash параметров:
      #          :object  - Any Type, объект для которого расчитываются переменные.
      #          :view_context - View.
      #          :args - Массив параметров для вычисления переменной (опционально).
      #
      # Если для переменной задан :source_class, то получает значение через него.
      # Если класс - источник не задан, а задан :source_proc, то вычисляет через него.
      #
      # Returns String.
      # Raises ArgumentError если переменная имеет не корректные свойства.

      def raw_value(params)
        if (source_class = self[:source_class]).present?
          source_params = self[:source_params].merge(:object => params[:object])
          source_class.value_as_string(source_params)
        elsif (source_proc = self[:source_proc]).present?
          proc_value(source_proc, params)
        else
          raise ArgumentError
        end
      end

      # Protected: Вычисляет значение source_proc.
      # Обертка для перекрытия в наследнике, для организации
      #   передачи более специфичного и точного списка параметров.
      #
      # See raw_value.
      #
      # Returns String.
      def proc_value(source_proc, params)
        source_proc.call(params[:view_context], params[:object], params[:args])
      end

      def method_missing(symbol, *args)
        if self.has_key?(symbol)
          self[symbol]
        else
          super
        end
      end
    end

  end
end