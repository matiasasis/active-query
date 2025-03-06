# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Define Query' do
  let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }
  let!(:dummy2) { DummyModel.create!(name: 'Dummy2', active: true, number: 1) }

  describe '.query' do
    context 'when query is a lambda' do
      context 'when query has no args' do
        subject { DummyModels::Query.count }

        it 'returns the amount of dummy models' do
          expect(subject).to eq(2)
        end
      end

      context 'when query has args' do
        subject { DummyModels::Query.by_name(name: 'Dummy2') }

        it 'returns the dummy model that exactly matches the name' do
          expect(subject.size).to eq(1)
          expect(subject).to include(dummy2)
        end

        context 'when invalid arg type is given' do
          subject { DummyModels::Query.by_name(name: 10) }

          it 'returns corresponding to the invalid argument type' do
            expect { subject }.to raise_error(ArgumentError, ':name must be of type String')
          end
        end
      end
    end

    context 'when query is a resolver' do
      context 'when query has no args' do
        subject { DummyModels::Query.count_resolver }

        it 'returns the amount of dummy models' do
          expect(subject).to eq(2)
        end
      end

      context 'when query has args' do
        subject { DummyModels::Query.by_name_resolver(name: 'Dummy2') }

        it 'returns the dummy model that exactly matches the name' do
          expect(subject.size).to eq(1)
          expect(subject).to include(dummy2)
        end

        context 'when invalid arg type is given' do
          subject { DummyModels::Query.by_name_resolver(name: 10) }

          it 'returns corresponding to the invalid argument type' do
            expect { subject }.to raise_error(ArgumentError, ':name must be of type String')
          end
        end
      end
    end
  end
end
