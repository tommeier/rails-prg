ENV["RAILS_ENV"]  ||= 'test'
ENV["RAILS_ROOT"] ||= File.expand_path("../dummy", __FILE__)

require_relative 'support/use_simplecov'
require_relative '../lib/rails/prg.rb'

# Load Dummy app
require File.expand_path("../dummy/config/environment", __FILE__)

require 'rails/prg'
require 'rspec/rails'
require 'capybara'

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end




