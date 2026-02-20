# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::DateTimeFilter do
  subject(:filter) { described_class.new(:timestamp) }

  describe '#process' do
    it 'passes through DateTime objects' do
      dt = DateTime.new(2024, 1, 15, 10, 30)
      expect(filter.process(dt)).to eq(dt)
    end

    it 'passes through Time objects' do
      time = Time.new(2024, 1, 15, 10, 30)
      expect(filter.process(time)).to eq(time)
    end

    it 'coerces valid datetime strings' do
      result = filter.process('2024-01-15T10:30:00')
      expect(result).to be_a(DateTime)
      expect(result.year).to eq(2024)
      expect(result.month).to eq(1)
      expect(result.day).to eq(15)
    end

    it 'coerces Date to DateTime' do
      date = Date.new(2024, 1, 15)
      result = filter.process(date)
      expect(result).to be_a(DateTime)
      expect(result.year).to eq(2024)
    end

    it 'raises for invalid datetime strings' do
      expect { filter.process('not-a-datetime') }.to raise_error(ArgumentError, ':timestamp must be of type DateTime')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
