# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::TypeRegistry do
  describe '.valid?' do
    context 'with default is_a? validation' do
      it 'accepts a String value for String type' do
        expect(described_class.valid?(String, 'hello')).to be true
      end

      it 'rejects an Integer value for String type' do
        expect(described_class.valid?(String, 42)).to be false
      end

      it 'accepts an Integer value for Integer type' do
        expect(described_class.valid?(Integer, 42)).to be true
      end

      it 'accepts subclasses' do
        expect(described_class.valid?(String, Class.new(String).new('hi'))).to be true
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
        described_class.instance_variable_get(:@validators).delete(custom_type)
      end

      it 'uses the custom validator' do
        expect(described_class.valid?(custom_type, :foo)).to be true
        expect(described_class.valid?(custom_type, 'foo')).to be false
      end
    end
  end

  describe '.coerce' do
    context 'when no coercer is registered' do
      it 'returns the value unchanged' do
        expect(described_class.coerce(String, 42)).to eq(42)
      end
    end

    context 'when a coercer is registered' do
      before do
        described_class.register(Integer, coerce: ->(val) { val.to_i })
      end

      after do
        described_class.instance_variable_get(:@coercers).delete(Integer)
      end

      it 'coerces the value' do
        expect(described_class.coerce(Integer, '42')).to eq(42)
      end
    end
  end

  describe '.coercer?' do
    it 'returns false when no coercer is registered' do
      expect(described_class.coercer?(String)).to be false
    end

    it 'returns true when a coercer is registered' do
      described_class.register(Float, coerce: ->(val) { val.to_f })
      expect(described_class.coercer?(Float)).to be true
      described_class.instance_variable_get(:@coercers).delete(Float)
    end
  end

  describe 'global coercion via registry' do
    let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }

    before do
      described_class.register(Integer, coerce: ->(val) { val.to_i })
    end

    after do
      described_class.instance_variable_get(:@coercers).delete(Integer)
    end

    it 'coerces a string to integer through global registry for by_number query' do
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

    it 'raises when value is invalid and no coercion is defined' do
      expect { DummyModels::Query.by_number(number: '1') }.to raise_error(ArgumentError, ':number must be of type Integer')
    end
  end
end
