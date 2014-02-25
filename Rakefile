require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'cane/rake_task'

Dir.glob("lib/tasks/*.rake").all? do |rake_file|
  load(rake_file)
end

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc "Run all unit specs"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = <<-SPEC_OPTS \
      --require spec_helper    \
      --format progress        \
      --tag ~capybara_feature  \
      --colour
    SPEC_OPTS
  end

  desc "Run all feature specs"
  RSpec::Core::RakeTask.new(:features) do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = <<-SPEC_OPTS \
      --require spec_helper    \
      --format documentation   \
      --tag capybara_feature    \
      --colour
    SPEC_OPTS
  end
end


