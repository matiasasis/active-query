# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Operations' do
  let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }
  let!(:dummy2) { DummyModel.create!(name: 'Dummy2', active: true, number: 1) }
  let!(:dummy3) { DummyModel.create!(name: 'Dummy3', active: true, number: 2) }

  describe '.gt(greather than)' do
    subject { DummyModels::Query.greater_than }

    it 'return only Dummy3 because is the only one with number gt 1' do
      expect(subject).to contain_exactly(dummy3)
    end
  end

  describe '.gteq(greather than or equals)' do
    subject { DummyModels::Query.greater_than_or_equals }

    it 'return all three dummy models, they all have number either 1 or 2' do
      expect(subject).to contain_exactly(dummy1, dummy2, dummy3)
    end
  end


  describe '.lt(less than)' do
    subject { DummyModels::Query.less_than }

    it 'returns only Dummy1 and Dummy2 because they have number lt 2' do
      expect(subject).to contain_exactly(dummy1, dummy2)
    end
  end

  describe '.lteq(less than or equals)' do
    subject { DummyModels::Query.less_than_or_equals }

    it 'returns all three dummy models, they all have number either 1 or 2' do
      expect(subject).to contain_exactly(dummy1, dummy2, dummy3)
    end
  end

  describe '.like(like)' do
    subject { DummyModels::Query.like_name }

    it 'returns all three dummy models, they all have name containing "Dummy"' do
      expect(subject).to contain_exactly(dummy1, dummy2, dummy3)
    end
  end

  describe '.start_like(start like)' do
    subject { DummyModels::Query.start_like_name }

    it 'returns all three dummy models, they all have name starting with "Dummy"' do
      expect(subject).to contain_exactly(dummy1, dummy2, dummy3)
    end
  end

  describe '.end_like(end like)' do
    subject { DummyModels::Query.end_like_name }

    it 'returns only Dummy1 because it is the only one with name ending with "1"' do
      expect(subject).to contain_exactly(dummy1)
    end
  end
end
