# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Registry' do
  describe '.registry' do
    it 'returns an array of classes that include ActiveQuery::Base' do
      expect(ActiveQuery::Base.registry).to be_an(Array)
      expect(ActiveQuery::Base.registry).to include(DummyModels::Query)
    end

    it 'only contains classes that include ActiveQuery::Base' do
      expect(ActiveQuery::Base.registry).to all(satisfy { |klass|
        klass.ancestors.include?(ActiveQuery::Base)
      })
    end
  end
end
