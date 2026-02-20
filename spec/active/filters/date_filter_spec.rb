# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::DateFilter do
  subject(:filter) { described_class.new(:start_date) }

  describe '#process' do
    it 'passes through Date objects' do
      date = Date.new(2024, 1, 15)
      expect(filter.process(date)).to eq(date)
    end

    it 'coerces valid date strings' do
      expect(filter.process('2024-01-15')).to eq(Date.new(2024, 1, 15))
    end

    it 'coerces Time to Date' do
      time = Time.new(2024, 1, 15, 10, 30)
      expect(filter.process(time)).to eq(Date.new(2024, 1, 15))
    end

    it 'coerces DateTime to Date' do
      dt = DateTime.new(2024, 1, 15, 10, 30)
      expect(filter.process(dt)).to eq(Date.new(2024, 1, 15))
    end

    it 'raises for invalid date strings' do
      expect { filter.process('not-a-date') }.to raise_error(ArgumentError, ':start_date must be of type Date')
    end

    it 'raises for non-coercible types' do
      expect { filter.process(12345) }.to raise_error(ArgumentError, ':start_date must be of type Date')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
