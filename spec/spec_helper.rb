# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'  # Optional: Exclude test files from coverage stats
end

require 'rspec'
require 'active_query'
require 'database_cleaner/active_record'
require 'byebug'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

load "#{File.dirname(__FILE__)}/support/schema.rb"
require "#{File.dirname(__FILE__)}/support/models.rb"
require "#{File.dirname(__FILE__)}/support/queries/dummy_models/resolvers/count.rb"
require "#{File.dirname(__FILE__)}/support/queries/dummy_models/resolvers/by_name.rb"
require "#{File.dirname(__FILE__)}/support/queries/dummy_models/query.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
