# frozen_string_literal: true

module ActiveQuery
  module Filters
    class Base
      attr_reader :name, :options

      def initialize(name, **options)
        @name = name
        @options = options
      end

      def required?
        !options.key?(:default) && options[:optional] != true
      end

      def default
        options[:default]
      end

      def desc
        options[:desc]
      end

      def process(value)
        return value if value.nil?

        accepted_classes.any? { |klass| value.is_a?(klass) } ? value : cast(value)
      end

      private

      def accepted_classes
        raise NotImplementedError, "#{self.class} must implement #accepted_classes"
      end

      def cast(value)
        raise ArgumentError, ":#{name} must be of type #{type_name}"
      end

      def type_name
        self.class.name.split('::').last.sub('Filter', '')
      end
    end
  end
end
