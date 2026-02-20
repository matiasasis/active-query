# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::Registry do
  describe '.build' do
    context 'with :string type' do
      subject { described_class.build(:name, type: :string) }

      it { is_expected.to be_a(ActiveQuery::Filters::StringFilter) }
    end

    context 'with :integer type' do
      subject { described_class.build(:count, type: :integer) }

      it { is_expected.to be_a(ActiveQuery::Filters::IntegerFilter) }
    end

    context 'with :boolean type' do
      subject { described_class.build(:active, type: :boolean) }

      it { is_expected.to be_a(ActiveQuery::Filters::BooleanFilter) }
    end

    context 'with :date type' do
      subject { described_class.build(:start, type: :date) }

      it { is_expected.to be_a(ActiveQuery::Filters::DateFilter) }
    end

    context 'with :date_time type' do
      subject { described_class.build(:ts, type: :date_time) }

      it { is_expected.to be_a(ActiveQuery::Filters::DateTimeFilter) }
    end

    context 'with :symbol type' do
      subject { described_class.build(:status, type: :symbol) }

      it { is_expected.to be_a(ActiveQuery::Filters::SymbolFilter) }
    end

    context 'with :decimal type' do
      subject { described_class.build(:amount, type: :decimal) }

      it { is_expected.to be_a(ActiveQuery::Filters::DecimalFilter) }
    end

    context 'with :array type' do
      subject { described_class.build(:tags, type: :array) }

      it { is_expected.to be_a(ActiveQuery::Filters::ArrayFilter) }
    end

    context 'with :hash type' do
      subject { described_class.build(:opts, type: :hash) }

      it { is_expected.to be_a(ActiveQuery::Filters::HashFilter) }
    end

    context 'with unknown symbol type' do
      it 'raises an ArgumentError' do
        expect { described_class.build(:x, type: :unknown) }.to raise_error(ArgumentError, 'Unknown filter type: unknown')
      end
    end

    context 'with Class-based types (backward compatibility)' do
      context 'with String class' do
        subject { described_class.build(:name, type: String) }

        it { is_expected.to be_a(ActiveQuery::Filters::StringFilter) }
      end

      context 'with Integer class' do
        subject { described_class.build(:count, type: Integer) }

        it { is_expected.to be_a(ActiveQuery::Filters::IntegerFilter) }
      end

      context 'with legacy Boolean class' do
        subject { described_class.build(:active, type: ActiveQuery::Base::Boolean) }

        it { is_expected.to be_a(ActiveQuery::Filters::BooleanFilter) }
      end

      context 'with unrecognized class' do
        subject { described_class.build(:model, type: DummyModel) }

        it { is_expected.to be_a(ActiveQuery::Filters::RecordFilter) }
      end
    end
  end
end
