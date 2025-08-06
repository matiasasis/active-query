# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveQuery do
  describe 'version number' do
    it "has a version number" do
      expect(ActiveQuery::VERSION).not_to be nil
    end
  end
end
