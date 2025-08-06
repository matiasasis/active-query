# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Register Query' do
  describe '.queries' do
    context 'when query is a lambda' do
      context 'when query has no args' do
        subject { DummyModels::Query.queries }

        it 'returns the details count query' do
          expect(subject).to include({ name: :count, description: 'Returns DummyModel count' })
        end

        it 'returns the details by_name query' do
          expect(subject).to include({
            name: :by_name,
            description: 'Returns the dummy models that match exact name',
            args_def: { name: { type: String, optional: false } }
          })
        end

        it 'returns the details count_resolver query' do
          expect(subject).to include({
            name: :count_resolver, description: 'Returns DummyModel count through the resolver'
          })
        end

        it 'returns the details by_name_resolver query' do
          expect(subject).to include({
            name: :by_name_resolver,
            description: 'Returns the dummy models that match exact name through the resolver',
            args_def: { name: { type: String } }
          })
        end
      end
    end
  end
end
