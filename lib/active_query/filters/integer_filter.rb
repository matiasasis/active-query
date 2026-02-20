# frozen_string_literal: true

module ActiveQuery
  module Filters
    class IntegerFilter < Base
      private

      def accepted_classes
        [Integer]
      end

      def cast(value)
        Integer(value)
      rescue ::ArgumentError, ::TypeError
        raise ArgumentError, ":#{name} must be of type Integer"
      end
    end
  end
end
