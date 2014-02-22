require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'cane/rake_task'

Dir.glob("lib/tasks/*.rake").all? do |rake_file|
  load(rake_file)
end

RSpec::Core::RakeTask.new(:spec)
