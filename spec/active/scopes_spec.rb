# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Scopes' do
  let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }
  let!(:dummy2) { DummyModel.create!(name: 'Dummy2', active: true, number: 1) }
  let!(:dummy3) { DummyModel.create!(name: 'Dummy3', active: true, number: 2) }

  describe '.by_number' do
    context 'when calling a scope defined on the scopes module' do
      context 'when scope has arguments' do
        subject { DummyModels::Query.by_number(number: 1) }

        it 'returns the models that have number 1' do
          expect(subject).to contain_exactly(dummy1, dummy2)
        end
      end

      context 'when scope has no arguments' do
        subject { DummyModels::Query.count_with_scope }

        it 'returns the amount of models' do
          expect(subject).to eq(3)
        end
      end
    end
  end
end
