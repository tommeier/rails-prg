ENV["RAILS_ENV"]  ||= 'test'
ENV["RAILS_ROOT"] ||= File.expand_path("../dummy", __FILE__)

require_relative 'support/use_simplecov'
# TODO: When open sourced - use OpenSauce for multibrowser testing
require_relative 'support/use_selenium_display'
require_relative '../lib/rails/prg.rb'

# Load Dummy app
require File.expand_path("../dummy/config/environment", __FILE__)

require 'rails/prg'
require 'rspec/rails'
require 'rspec/its'
require 'capybara'
require 'database_cleaner'

Rails.backtrace_cleaner.remove_silencers!

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end
