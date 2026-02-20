# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::RecordFilter do
  let!(:dummy) { DummyModel.create!(name: 'Test', active: true, number: 1) }

  describe '#process' do
    context 'with class option' do
      subject(:filter) { described_class.new(:model, type: :record, class: DummyModel) }

      it 'passes through instances of the class' do
        expect(filter.process(dummy)).to eq(dummy)
      end

      it 'coerces integer ids via find' do
        expect(filter.process(dummy.id)).to eq(dummy)
      end

      it 'coerces string ids via find' do
        expect(filter.process(dummy.id.to_s)).to eq(dummy)
      end

      it 'raises for non-existent records' do
        expect { filter.process(999999) }.to raise_error(ArgumentError, /record not found/)
      end

      it 'returns nil for nil' do
        expect(filter.process(nil)).to be_nil
      end
    end

    context 'with string class option' do
      subject(:filter) { described_class.new(:model, type: :record, class: 'DummyModel') }

      it 'resolves the class from string and finds records' do
        expect(filter.process(dummy.id)).to eq(dummy)
      end
    end

    context 'with class as type (backward compat)' do
      subject(:filter) { described_class.new(:model, type: DummyModel) }

      it 'uses the type as the record class' do
        expect(filter.process(dummy)).to eq(dummy)
      end

      it 'coerces integer ids via find' do
        expect(filter.process(dummy.id)).to eq(dummy)
      end
    end
  end
end
