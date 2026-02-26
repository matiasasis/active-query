# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::TypeRegistry do
  describe '.valid?' do
    context 'with type class validation' do
      it 'accepts a String value for String type' do
        expect(described_class.valid?(String, 'hello')).to be true
      end

      it 'rejects an Integer value for String type' do
        expect(described_class.valid?(String, 42)).to be false
      end

      it 'accepts an Integer value for Integer type' do
        expect(described_class.valid?(Integer, 42)).to be true
      end
    end

    context 'with default is_a? validation for unregistered types' do
      let(:custom_type) { Class.new }

      it 'falls back to is_a? for unregistered types' do
        obj = custom_type.new
        expect(described_class.valid?(custom_type, obj)).to be true
      end

      it 'accepts subclasses with is_a? fallback' do
        sub = Class.new(custom_type)
        expect(described_class.valid?(custom_type, sub.new)).to be true
      end
    end

    context 'with Boolean validation' do
      it 'accepts true' do
        expect(described_class.valid?(ActiveQuery::Base::Boolean, true)).to be true
      end

      it 'accepts false' do
        expect(described_class.valid?(ActiveQuery::Base::Boolean, false)).to be true
      end

      it 'rejects a string' do
        expect(described_class.valid?(ActiveQuery::Base::Boolean, 'true')).to be false
      end

      it 'rejects nil' do
        expect(described_class.valid?(ActiveQuery::Base::Boolean, nil)).to be false
      end
    end

    context 'with a custom registered validator' do
      let(:custom_type) { Class.new }

      before do
        described_class.register(custom_type, validator: ->(val) { val.is_a?(Symbol) })
      end

      after do
        described_class.unregister(custom_type)
      end

      it 'uses the custom validator' do
        expect(described_class.valid?(custom_type, :foo)).to be true
        expect(described_class.valid?(custom_type, 'foo')).to be false
      end
    end
  end

  describe '.coerce' do
    context 'when no coercer or type class is registered' do
      let(:custom_type) { Class.new }

      it 'returns the value unchanged' do
        expect(described_class.coerce(custom_type, 42)).to eq(42)
      end
    end

    context 'with type class coercion' do
      it 'coerces a string to integer via type class' do
        expect(described_class.coerce(Integer, '42')).to eq(42)
      end

      it 'coerces an integer to string via type class' do
        expect(described_class.coerce(String, 42)).to eq('42')
      end
    end

    context 'when a lambda coercer is registered (takes priority)' do
      let(:custom_type) { Class.new }

      before do
        described_class.register(custom_type, coerce: ->(val) { val.to_s.upcase })
      end

      after do
        described_class.unregister(custom_type)
      end

      it 'uses the lambda coercer' do
        expect(described_class.coerce(custom_type, 'hello')).to eq('HELLO')
      end
    end
  end

  describe '.coercer?' do
    it 'returns false when no coercer or type class is registered' do
      custom_type = Class.new
      expect(described_class.coercer?(custom_type)).to be false
    end

    it 'returns true when a type class is registered' do
      expect(described_class.coercer?(String)).to be true
    end

    it 'returns true when a lambda coercer is registered' do
      custom_type = Class.new
      described_class.register(custom_type, coerce: ->(val) { val })
      expect(described_class.coercer?(custom_type)).to be true
      described_class.unregister(custom_type)
    end
  end

  describe '.unregister' do
    it 'removes type class registration' do
      custom_type = Class.new
      type_class = Class.new(ActiveQuery::Types::Base) do
        def self.valid?(value) = value.is_a?(Symbol)
        def self.coerce(value) = value.to_sym
      end

      described_class.register(custom_type, type_class: type_class)
      expect(described_class.coercer?(custom_type)).to be true

      described_class.unregister(custom_type)
      expect(described_class.coercer?(custom_type)).to be false
    end

    it 'falls back to is_a? validation after unregister' do
      custom_type = Class.new
      type_class = Class.new(ActiveQuery::Types::Base) do
        def self.valid?(_value) = true
      end

      described_class.register(custom_type, type_class: type_class)
      expect(described_class.valid?(custom_type, 'anything')).to be true

      described_class.unregister(custom_type)
      expect(described_class.valid?(custom_type, 'anything')).to be false
      expect(described_class.valid?(custom_type, custom_type.new)).to be true
    end

    it 'removes lambda validators and coercers' do
      custom_type = Class.new
      described_class.register(custom_type, validator: ->(_) { true }, coerce: ->(v) { v })

      described_class.unregister(custom_type)
      expect(described_class.coercer?(custom_type)).to be false
    end
  end

  describe 'global coercion via type class' do
    let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }

    it 'coerces a string to integer through type class for by_number query' do
      result = DummyModels::Query.by_number(number: '1')
      expect(result).to include(dummy1)
    end
  end

  describe 'per-argument coercion' do
    let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }

    it 'coerces a string to integer via per-argument coerce option' do
      result = DummyModels::Query.by_number_coerced(number: '1')
      expect(result).to include(dummy1)
    end
  end

  describe 'coercion runs before validation' do
    let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }

    it 'does not raise when coercion produces a valid type' do
      expect { DummyModels::Query.by_number_coerced(number: '1') }.not_to raise_error
    end

    it 'coerces via type class and does not raise' do
      expect { DummyModels::Query.by_number(number: '1') }.not_to raise_error
    end
  end
end
