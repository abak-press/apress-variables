# coding: utf-8
require_relative 'dsl/variable'

module Apress
  module Variables
    class Variable
      include ::Apress::Variables::Dsl::Variable

      attr_reader :context

      attr_accessor :id
      attr_accessor :name
      attr_accessor :desc
      attr_accessor :type
      attr_accessor :default
      attr_accessor :rate
      attr_accessor :max_rate

      attr_accessor :source_class
      attr_accessor :source_params
      attr_accessor :source_proc

      attr_reader :groups
      attr_reader :classes

      attr_accessor :options

      def initialize
        self.options = HashWithIndifferentAccess.new
        self.context = Array.new
      end

      # Public: Возвращает имя переменной.
      #
      # Returns String.
      #
      def pretty_name
        (name || id).to_s
      end

      # Public: Вычисляет и возвращает значение переменной.
      #
      # params - Hash, параметры для которых расчитываются переменные.
      # args   - Array - массив аргументов для вычисления переменной (опционально).
      #
      # Если для переменной задан :source_class, то получает значение через него.
      # Если класс - источник не задан, а задан :source_proc, то вычисляет через него.
      #
      # Returns String.
      # Raises ArgumentError если переменная имеет не корректные свойства.
      #
      def value(params, args = [])
        if source_class.present?
          params = source_params.merge(:object => params)
          source_class.value_as_string(params)
        elsif source_proc.present?
          proc_value(source_proc, params, args)
        else
          raise ArgumentError, [params, args].inspect
        end
      end

      # Public: Является ли переменная "редиректом".
      #
      # Returns Boolean.
      #
      def redirect?
        id.to_s.end_with?('redirect')
      end

      def for_class?(klass)
        classes.nil? || classes.first.eql?(:all) ||
          (classes.map(&:to_s) & Array.wrap(klass).map(&:to_s)).present?
      end

      def for_group?(group)
        groups.nil? || groups.first.eql?(:all) ||
          (groups.map(&:to_s) & Array.wrap(group).map(&:to_s)).present?
      end

      def groups=(value_or_array)
        @groups = Array.wrap(value_or_array) if value_or_array.present?
      end

      def classes=(value_or_array)
        @classes = Array.wrap(value_or_array) if value_or_array.present?
      end

      def context=(value)
        @context = value.nil? ? [] : value
      end

      protected

      # Protected: Вычисляет значение source_proc.
      # Обертка для перекрытия в наследнике, для организации
      # передачи более специфичного и точного списка параметров.
      #
      # See value.
      #
      # Returns String.
      #
      def proc_value(source_proc, params, args)
        source_proc.call(params, args)
      end

      def value_with_rate(params, args = [])
        value = value_without_rate(params, args)

        if rate.present?
          value = value.to_i * rate
          value = max_rate if max_rate.present? && value > max_rate
        end

        value
      end

      def value_with_formatting(params, args = [])
        value = value_without_formatting(params, args)

        case type
        when :integer
          value.to_i
        else
          if value.blank? && default
            default
          else
            value
          end
        end.to_s
      end

      alias_method_chain :value, :rate
      alias_method_chain :value, :formatting
    end
  end
end
