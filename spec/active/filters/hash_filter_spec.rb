# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::HashFilter do
  describe '#process' do
    context 'without value_type' do
      subject(:filter) { described_class.new(:options) }

      it 'passes through hashes' do
        expect(filter.process({ a: 1, b: 'two' })).to eq({ a: 1, b: 'two' })
      end

      it 'raises for non-hashes' do
        expect { filter.process('not a hash') }.to raise_error(ArgumentError, ':options must be of type Hash')
      end

      it 'returns nil for nil' do
        expect(filter.process(nil)).to be_nil
      end
    end

    context 'with value_type' do
      subject(:filter) { described_class.new(:options, value_type: :integer) }

      it 'coerces values to the specified type' do
        expect(filter.process({ a: '1', b: '2' })).to eq({ a: 1, b: 2 })
      end

      it 'passes through correctly typed values' do
        expect(filter.process({ a: 1, b: 2 })).to eq({ a: 1, b: 2 })
      end
    end
  end
end
