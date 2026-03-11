# frozen_string_literal: true

module ActiveQuery
  module Types
    class String < Base
      def self.valid?(value)
        value.is_a?(::String)
      end

      def self.coerce(value)
        value.to_s
      end
    end
  end
end
