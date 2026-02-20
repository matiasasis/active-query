# frozen_string_literal: true

module ActiveQuery
  module Filters
    class ArrayFilter < Base
      def process(value)
        return value if value.nil?

        raise ArgumentError, ":#{name} must be of type Array" unless value.is_a?(Array)

        if options[:element_type]
          element_filter = Registry.build(:"#{name}[]", type: options[:element_type])
          value.map { |el| element_filter.process(el) }
        else
          value
        end
      end

      private

      def accepted_classes
        [Array]
      end
    end
  end
end
