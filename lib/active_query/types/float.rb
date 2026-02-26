# frozen_string_literal: true

module ActiveQuery
  module Types
    class Float < Base
      def self.valid?(value)
        value.is_a?(::Float)
      end

      def self.coerce(value)
        ::Kernel.Float(value)
      rescue ArgumentError, TypeError
        value
      end
    end
  end
end
