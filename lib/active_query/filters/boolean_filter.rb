# frozen_string_literal: true

module ActiveQuery
  module Filters
    class BooleanFilter < Base
      TRUE_VALUES = [true, 'true', '1', 1].freeze
      FALSE_VALUES = [false, 'false', '0', 0].freeze

      private

      def accepted_classes
        [TrueClass, FalseClass]
      end

      def cast(value)
        return true if TRUE_VALUES.include?(value)
        return false if FALSE_VALUES.include?(value)

        raise ArgumentError, ":#{name} must be of type Boolean"
      end
    end
  end
end
