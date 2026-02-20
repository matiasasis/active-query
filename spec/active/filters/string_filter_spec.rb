# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::StringFilter do
  subject(:filter) { described_class.new(:name) }

  describe '#process' do
    it 'passes through strings' do
      expect(filter.process('hello')).to eq('hello')
    end

    it 'coerces integers to strings' do
      expect(filter.process(42)).to eq('42')
    end

    it 'coerces symbols to strings' do
      expect(filter.process(:hello)).to eq('hello')
    end

    it 'returns nil for nil' do
      expect(filter.process(nil)).to be_nil
    end
  end
end
