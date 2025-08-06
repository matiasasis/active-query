# frozen_string_literal: true

require 'spec_helper'

class DummyModelQueryObjectModelName
  include ::ActiveQuery::Base
  model_name 'DummyModel'
end

class DummyModelQueryObjectNoModelName
  include ::ActiveQuery::Base
end

RSpec.describe 'Model Name' do
  describe '.model_name' do
    context 'when model_name is given' do
      subject { DummyModelQueryObjectModelName.model }

      it 'returns the model that was set' do
        expect(subject).to eq(DummyModel)
      end
    end

    context 'when model_name is not given and has to infer it' do
      subject { DummyModels::Query.model }

      it 'returns the model that was inferred' do
        expect(subject).to eq(DummyModel)
      end
    end
  end
end
