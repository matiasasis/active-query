# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :dummy_models, force: true do |t|
    t.string :name
    t.boolean :active
    t.integer :number

    t.timestamps
  end
end
