# frozen_string_literal: true

require_relative 'types/base'
require_relative 'types/string'
require_relative 'types/integer'
require_relative 'types/float'
require_relative 'types/boolean'

module ActiveQuery
  module TypeRegistry
    @validators = {}
    @coercers = {}
    @type_classes = {}

    def self.register(type, validator: nil, coerce: nil, type_class: nil)
      @validators[type] = validator if validator
      @coercers[type] = coerce if coerce
      @type_classes[type] = type_class if type_class
    end

    def self.unregister(type)
      @validators.delete(type)
      @coercers.delete(type)
      @type_classes.delete(type)
    end

    def self.valid?(type, value)
      if @validators.key?(type)
        @validators[type].call(value)
      elsif @type_classes.key?(type)
        @type_classes[type].valid?(value)
      else
        value.is_a?(type)
      end
    end

    def self.coerce(type, value)
      if @coercers.key?(type)
        @coercers[type].call(value)
      elsif @type_classes.key?(type)
        @type_classes[type].coerce(value)
      else
        value
      end
    end

    def self.coercer?(type)
      @coercers.key?(type) || @type_classes.key?(type)
    end

    register(String, type_class: Types::String)
    register(Integer, type_class: Types::Integer)
    register(Float, type_class: Types::Float)
  end
end
