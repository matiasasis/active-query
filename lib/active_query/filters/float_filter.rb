# frozen_string_literal: true

module ActiveQuery
  module Filters
    class FloatFilter < Base
      private

      def accepted_classes
        [Float, Integer]
      end

      def cast(value)
        Float(value)
      rescue ::ArgumentError, ::TypeError
        raise ArgumentError, ":#{name} must be of type Float"
      end
    end
  end
end
