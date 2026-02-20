# frozen_string_literal: true

require 'spec_helper'
require 'bigdecimal'

RSpec.describe ActiveQuery::Filters::DecimalFilter do
  subject(:filter) { described_class.new(:amount) }

  describe '#process' do
    it 'passes through BigDecimal objects' do
      bd = BigDecimal('10.5')
      expect(filter.process(bd)).to eq(bd)
    end

    it 'coerces strings to BigDecimal' do
      expect(filter.process('10.5')).to eq(BigDecimal('10.5'))
    end

    it 'coerces integers to BigDecimal' do
      expect(filter.process(10)).to eq(BigDecimal('10'))
    end

    it 'coerces floats to BigDecimal' do
      result = filter.process(10.5)
      expect(result).to be_a(BigDecimal)
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
