# frozen_string_literal: true

module ActiveQuery
  module Types
    class Base
      def self.valid?(_value)
        raise NotImplementedError, "#{name} must implement .valid?"
      end

      def self.coerce(value)
        value
      end
    end
  end
end
