# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::IntegerFilter do
  subject(:filter) { described_class.new(:count) }

  describe '#process' do
    it 'passes through integers' do
      expect(filter.process(42)).to eq(42)
    end

    it 'coerces string integers' do
      expect(filter.process('42')).to eq(42)
    end

    it 'raises for non-numeric strings' do
      expect { filter.process('abc') }.to raise_error(ArgumentError, ':count must be of type Integer')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
