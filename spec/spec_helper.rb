ENV["RAILS_ENV"] ||= 'test'
require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
end

require_relative '../lib/rails/prg.rb'

# Load Dummy app
require File.expand_path("../dummy/config/environment", __FILE__)

require 'rails/prg'
require 'rspec/rails'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end


