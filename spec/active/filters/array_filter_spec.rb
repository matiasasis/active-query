# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery::Filters::ArrayFilter do
  describe '#process' do
    context 'without element_type' do
      subject(:filter) { described_class.new(:tags) }

      it 'passes through arrays' do
        expect(filter.process([1, 'two', :three])).to eq([1, 'two', :three])
      end

      it 'raises for non-arrays' do
        expect { filter.process('not an array') }.to raise_error(ArgumentError, ':tags must be of type Array')
      end

      it 'returns nil for nil' do
        expect(filter.process(nil)).to be_nil
      end
    end

    context 'with element_type' do
      subject(:filter) { described_class.new(:tags, element_type: :string) }

      it 'coerces elements to the specified type' do
        expect(filter.process([1, 2, 3])).to eq(['1', '2', '3'])
      end

      it 'passes through correctly typed elements' do
        expect(filter.process(['a', 'b'])).to eq(['a', 'b'])
      end
    end
  end
end
