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

    it 'registers classes that include ActiveQuery::Base through an intermediary concern' do
      intermediary = Module.new do
        extend ActiveSupport::Concern
        include ActiveQuery::Base
      end

      query_class = Class.new do
        include intermediary
      end

      expect(ActiveQuery::Base.registry).to include(query_class)
    end
  end
end
