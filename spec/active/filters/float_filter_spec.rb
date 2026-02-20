# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::FloatFilter do
  subject(:filter) { described_class.new(:price) }

  describe '#process' do
    it 'passes through floats' do
      expect(filter.process(3.14)).to eq(3.14)
    end

    it 'passes through integers (is_a? accepts Integer)' do
      expect(filter.process(42)).to eq(42)
    end

    it 'coerces string floats' do
      expect(filter.process('3.14')).to eq(3.14)
    end

    it 'raises for non-numeric strings' do
      expect { filter.process('abc') }.to raise_error(ArgumentError, ':price must be of type Float')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
