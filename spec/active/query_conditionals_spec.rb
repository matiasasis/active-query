# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arguments' do
  before(:all) do
    DummyModel.create!(name: 'Dummy1', active: false, number: 1)
    DummyModel.create!(name: 'Dummy2', active: true, number: 1)
    DummyModel.create!(name: 'Dummy3', active: true, number: 2)
  end

  describe '.query' do
    context '.if' do
      context 'when active is provided' do
        subject { DummyModels::Query.number_if_active(number: 1, active: true) }

        it 'return only DummyModel 2' do
          expect(subject).to contain_exactly(DummyModel.find_by(name: 'Dummy2'))
        end
      end

      context 'when active is not provided' do
        subject { DummyModels::Query.number_if_active(number: 1) }

        it 'return Dummy1 and Dummy2, because is not filtering by active' do
          expect(subject).to contain_exactly(
            DummyModel.find_by(name: 'Dummy1'),
            DummyModel.find_by(name: 'Dummy2')
          )
        end
      end
    end

    context '.unless' do
      context 'when active is provided' do
        subject { DummyModels::Query.number_unless_active(number: 1, active: true) }

        it 'return only Dummy1 and Dummy2, because query only filters by active if not present' do
          expect(subject).to contain_exactly(
            DummyModel.find_by(name: 'Dummy1'),
            DummyModel.find_by(name: 'Dummy2')
          )
        end
      end

      context 'when active is not provided' do
        subject { DummyModels::Query.number_unless_active(number: 1) }

        it 'return Dummy2, because if active is not provided query filters by active' do
          expect(subject).to contain_exactly(DummyModel.find_by(name: 'Dummy2'))
        end
      end
    end
  end
end
