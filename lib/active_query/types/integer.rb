# frozen_string_literal: true

module ActiveQuery
  module Types
    class Integer < Base
      def self.valid?(value)
        value.is_a?(::Integer)
      end

      def self.coerce(value)
        ::Kernel.Integer(value, 10)
      rescue ArgumentError, TypeError
        value
      end
    end
  end
end
