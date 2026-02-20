# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::Registry do
  describe '.build' do
    it 'builds a StringFilter for :string type' do
      filter = described_class.build(:name, type: :string)
      expect(filter).to be_a(ActiveQuery::Filters::StringFilter)
    end

    it 'builds an IntegerFilter for :integer type' do
      filter = described_class.build(:count, type: :integer)
      expect(filter).to be_a(ActiveQuery::Filters::IntegerFilter)
    end

    it 'builds a BooleanFilter for :boolean type' do
      filter = described_class.build(:active, type: :boolean)
      expect(filter).to be_a(ActiveQuery::Filters::BooleanFilter)
    end

    it 'builds a DateFilter for :date type' do
      filter = described_class.build(:start, type: :date)
      expect(filter).to be_a(ActiveQuery::Filters::DateFilter)
    end

    it 'builds a DateTimeFilter for :date_time type' do
      filter = described_class.build(:ts, type: :date_time)
      expect(filter).to be_a(ActiveQuery::Filters::DateTimeFilter)
    end

    it 'builds a SymbolFilter for :symbol type' do
      filter = described_class.build(:status, type: :symbol)
      expect(filter).to be_a(ActiveQuery::Filters::SymbolFilter)
    end

    it 'builds a DecimalFilter for :decimal type' do
      filter = described_class.build(:amount, type: :decimal)
      expect(filter).to be_a(ActiveQuery::Filters::DecimalFilter)
    end

    it 'builds an ArrayFilter for :array type' do
      filter = described_class.build(:tags, type: :array)
      expect(filter).to be_a(ActiveQuery::Filters::ArrayFilter)
    end

    it 'builds a HashFilter for :hash type' do
      filter = described_class.build(:opts, type: :hash)
      expect(filter).to be_a(ActiveQuery::Filters::HashFilter)
    end

    it 'raises for unknown symbol type' do
      expect { described_class.build(:x, type: :unknown) }.to raise_error(ArgumentError, 'Unknown filter type: unknown')
    end

    context 'with Class-based types (backward compatibility)' do
      it 'builds a StringFilter for String class' do
        filter = described_class.build(:name, type: String)
        expect(filter).to be_a(ActiveQuery::Filters::StringFilter)
      end

      it 'builds an IntegerFilter for Integer class' do
        filter = described_class.build(:count, type: Integer)
        expect(filter).to be_a(ActiveQuery::Filters::IntegerFilter)
      end

      it 'builds a BooleanFilter for legacy Boolean class' do
        filter = described_class.build(:active, type: ActiveQuery::Base::Boolean)
        expect(filter).to be_a(ActiveQuery::Filters::BooleanFilter)
      end

      it 'builds a RecordFilter for unrecognized classes' do
        filter = described_class.build(:model, type: DummyModel)
        expect(filter).to be_a(ActiveQuery::Filters::RecordFilter)
      end
    end
  end
end
