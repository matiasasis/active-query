# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query Execution' do
  describe 'type coercion' do
    def coerce_value(value, type)
      case type&.name
      when "Integer" then Integer(value)
      when "Float" then Float(value)
      when "ActiveQuery::Base::Boolean" then value == "true" || value == "1"
      else value.to_s
      end
    end

    it 'coerces string to Integer' do
      expect(coerce_value("42", Integer)).to eq(42)
    end

    it 'raises on invalid Integer' do
      expect { coerce_value("abc", Integer) }.to raise_error(ArgumentError)
    end

    it 'coerces string to Float' do
      expect(coerce_value("3.14", Float)).to eq(3.14)
    end

    it 'coerces string to Boolean true' do
      expect(coerce_value("true", ActiveQuery::Base::Boolean)).to eq(true)
    end

    it 'coerces string to Boolean false' do
      expect(coerce_value("false", ActiveQuery::Base::Boolean)).to eq(false)
    end

    it 'passes strings through' do
      expect(coerce_value("hello", String)).to eq("hello")
    end
  end

  describe 'result serialization' do
    def serialize_result(result)
      case result
      when ActiveRecord::Relation then result.limit(100).as_json
      when Integer, Float, String, NilClass, TrueClass, FalseClass then result
      when ActiveRecord::Base then result.as_json
      when Enumerable then result.first(100).as_json
      else result.as_json
      end
    end

    it 'serializes an integer directly' do
      expect(serialize_result(42)).to eq(42)
    end

    it 'serializes a string directly' do
      expect(serialize_result("hello")).to eq("hello")
    end

    it 'serializes nil directly' do
      expect(serialize_result(nil)).to eq(nil)
    end

    it 'serializes a boolean directly' do
      expect(serialize_result(true)).to eq(true)
    end

    it 'serializes an array with limit' do
      big_array = (1..200).to_a
      result = serialize_result(big_array)
      expect(result.length).to eq(100)
    end

    it 'serializes an ActiveRecord::Relation' do
      DummyModel.create!(name: "Test", number: 1, active: true)
      result = serialize_result(DummyModel.all)
      expect(result).to be_an(Array)
      expect(result.first).to have_key("name")
    end
  end
end
