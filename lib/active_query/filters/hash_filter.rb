# frozen_string_literal: true

module ActiveQuery
  module Filters
    class HashFilter < Base
      def process(value)
        return value if value.nil?

        raise ArgumentError, ":#{name} must be of type Hash" unless value.is_a?(Hash)

        if options[:value_type]
          value_filter = Registry.build(:"#{name}[]", type: options[:value_type])
          value.transform_values { |v| value_filter.process(v) }
        else
          value
        end
      end

      private

      def accepted_classes
        [Hash]
      end
    end
  end
end
