# frozen_string_literal: true

require 'spec_helper'

class DummyModelQueryObject
  include ::ActiveQuery::Base
  model_name 'DummyModel'

  query :count, 'Returns the amount of dummy models',
    -> { scope.count }
end

RSpec.describe ActiveQuery do
  describe 'version number' do
    it "has a version number" do
      expect(ActiveQuery::VERSION).not_to be nil
    end
  end

  describe '.model_name' do
    context 'when model_name is given' do

      subject { DummyModelQueryObject.count }

      before { DummyModel.create!(name: 'Dummy') }

      it 'returns the amount of dummy models' do
        expect(subject).to eq(1)
      end

    end
  end

  describe '.query' do
    context 'when lambda is given as resolver' do
      context 'when query has no params' do
        subject { DummyModelQueryObject.count }

        before { DummyModel.create!(name: 'Dummy') }

        it 'returns the amount of dummy models' do
          expect(subject).to eq(1)
        end
      end
    end
  end
end
