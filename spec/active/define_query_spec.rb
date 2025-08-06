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

    context 'when query is invalid' do
      context 'when no arguments given' do
        subject { DummyModels::Query.query() }

        it 'returns the amount of dummy models' do
          expect { subject }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 2..4)')
        end
      end

      context 'when resolver is not provided' do
        subject { DummyModels::Query.query(:fake, 'fake description') }

        it 'returns the amount of dummy models' do
          expect { subject }.to raise_error(ArgumentError, 'Invalid query definition')
        end
      end

      context 'when empty name' do
        subject { DummyModels::Query.query('', 'fake description', -> { where(number: 2) }) }

        it 'returns the amount of dummy models' do
          expect { subject }.to raise_error(ArgumentError, 'name must be present')
        end
      end
    end
  end
end
