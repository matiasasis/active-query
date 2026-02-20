# frozen_string_literal: true

module ActiveQuery
  module Filters
    class SymbolFilter < Base
      private

      def accepted_classes
        [Symbol]
      end

      def cast(value)
        case value
        when String
          value.to_sym
        else
          raise ArgumentError, ":#{name} must be of type Symbol"
        end
      end
    end
  end
end
