# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::SymbolFilter do
  subject(:filter) { described_class.new(:status) }

  describe '#process' do
    it 'passes through symbols' do
      expect(filter.process(:active)).to eq(:active)
    end

    it 'coerces strings to symbols' do
      expect(filter.process('active')).to eq(:active)
    end

    it 'raises for non-coercible types' do
      expect { filter.process(123) }.to raise_error(ArgumentError, ':status must be of type Symbol')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
