# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::BooleanFilter do
  subject(:filter) { described_class.new(:active) }

  describe '#process' do
    it 'passes through true' do
      expect(filter.process(true)).to eq(true)
    end

    it 'passes through false' do
      expect(filter.process(false)).to eq(false)
    end

    it 'coerces "true" to true' do
      expect(filter.process('true')).to eq(true)
    end

    it 'coerces "false" to false' do
      expect(filter.process('false')).to eq(false)
    end

    it 'coerces "1" to true' do
      expect(filter.process('1')).to eq(true)
    end

    it 'coerces "0" to false' do
      expect(filter.process('0')).to eq(false)
    end

    it 'coerces 1 to true' do
      expect(filter.process(1)).to eq(true)
    end

    it 'coerces 0 to false' do
      expect(filter.process(0)).to eq(false)
    end

    it 'raises for non-boolean values' do
      expect { filter.process('maybe') }.to raise_error(ArgumentError, ':active must be of type Boolean')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
