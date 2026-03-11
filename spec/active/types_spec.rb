# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Types do
  describe ActiveQuery::Types::Base do
    it 'raises NotImplementedError for .valid?' do
      expect { described_class.valid?('x') }.to raise_error(NotImplementedError)
    end

    it 'returns the value unchanged from .coerce' do
      expect(described_class.coerce('x')).to eq('x')
    end
  end

  describe ActiveQuery::Types::String do
    describe '.valid?' do
      it 'accepts a String' do
        expect(described_class.valid?('hello')).to be true
      end

      it 'rejects an Integer' do
        expect(described_class.valid?(42)).to be false
      end

      it 'rejects nil' do
        expect(described_class.valid?(nil)).to be false
      end
    end

    describe '.coerce' do
      it 'converts an Integer to String' do
        expect(described_class.coerce(42)).to eq('42')
      end

      it 'converts a Symbol to String' do
        expect(described_class.coerce(:hello)).to eq('hello')
      end

      it 'returns a String unchanged' do
        expect(described_class.coerce('hello')).to eq('hello')
      end
    end
  end

  describe ActiveQuery::Types::Integer do
    describe '.valid?' do
      it 'accepts an Integer' do
        expect(described_class.valid?(42)).to be true
      end

      it 'rejects a String' do
        expect(described_class.valid?('42')).to be false
      end

      it 'rejects a Float' do
        expect(described_class.valid?(1.5)).to be false
      end
    end

    describe '.coerce' do
      it 'converts a numeric string to Integer' do
        expect(described_class.coerce('42')).to eq(42)
      end

      it 'returns original value for non-numeric string' do
        expect(described_class.coerce('abc')).to eq('abc')
      end

      it 'returns an Integer unchanged' do
        expect(described_class.coerce(42)).to eq(42)
      end
    end
  end

  describe ActiveQuery::Types::Float do
    describe '.valid?' do
      it 'accepts a Float' do
        expect(described_class.valid?(1.5)).to be true
      end

      it 'rejects an Integer' do
        expect(described_class.valid?(42)).to be false
      end

      it 'rejects a String' do
        expect(described_class.valid?('1.5')).to be false
      end
    end

    describe '.coerce' do
      it 'converts a numeric string to Float' do
        expect(described_class.coerce('1.5')).to eq(1.5)
      end

      it 'converts an Integer to Float' do
        expect(described_class.coerce(42)).to eq(42.0)
      end

      it 'returns original value for non-numeric string' do
        expect(described_class.coerce('abc')).to eq('abc')
      end

      it 'returns a Float unchanged' do
        expect(described_class.coerce(1.5)).to eq(1.5)
      end
    end
  end

  describe ActiveQuery::Types::Boolean do
    describe '.valid?' do
      it 'accepts true' do
        expect(described_class.valid?(true)).to be true
      end

      it 'accepts false' do
        expect(described_class.valid?(false)).to be true
      end

      it 'rejects a string' do
        expect(described_class.valid?('true')).to be false
      end

      it 'rejects nil' do
        expect(described_class.valid?(nil)).to be false
      end
    end

    describe '.coerce' do
      it 'coerces "true" to true' do
        expect(described_class.coerce('true')).to be true
      end

      it 'coerces "false" to false' do
        expect(described_class.coerce('false')).to be false
      end

      it 'coerces "1" to true' do
        expect(described_class.coerce('1')).to be true
      end

      it 'coerces "0" to false' do
        expect(described_class.coerce('0')).to be false
      end

      it 'coerces 1 to true' do
        expect(described_class.coerce(1)).to be true
      end

      it 'coerces 0 to false' do
        expect(described_class.coerce(0)).to be false
      end

      it 'returns true unchanged' do
        expect(described_class.coerce(true)).to be true
      end

      it 'returns false unchanged' do
        expect(described_class.coerce(false)).to be false
      end

      it 'returns unrecognized values unchanged' do
        expect(described_class.coerce('maybe')).to eq('maybe')
      end
    end
  end
end
