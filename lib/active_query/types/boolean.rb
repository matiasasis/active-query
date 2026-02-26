# frozen_string_literal: true

module ActiveQuery
  module Types
    class Boolean < Base
      def self.to_s = 'Boolean'
      def self.inspect = 'Boolean'

      TRUTHY = [true, 'true', '1', 1].freeze
      FALSY = [false, 'false', '0', 0].freeze

      def self.valid?(value)
        value == true || value == false
      end

      def self.coerce(value)
        return true if TRUTHY.include?(value)
        return false if FALSY.include?(value)

        value
      end
    end
  end
end
