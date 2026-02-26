# frozen_string_literal: true

module ActiveQuery
  module TypeRegistry
    @validators = {}
    @coercers = {}

    def self.register(type, validator: nil, coerce: nil)
      @validators[type] = validator if validator
      @coercers[type] = coerce if coerce
    end

    def self.valid?(type, value)
      validator = @validators[type] || ->(val) { val.is_a?(type) }
      validator.call(value)
    end

    def self.coerce(type, value)
      coercer = @coercers[type]
      coercer ? coercer.call(value) : value
    end

    def self.coercer?(type)
      @coercers.key?(type)
    end
  end
end
