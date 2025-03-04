# frozen_string_literal: true

class DummyModel < ActiveRecord::Base
  self.table_name = :dummy_models

  validates_presence_of :name
end
