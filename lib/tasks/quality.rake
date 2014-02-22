if defined? RSpec
  namespace :spec do
    begin
      require 'cane/rake_task'

      desc "Run cane to check quality metrics"
      Cane::RakeTask.new(:quality) do |cane|
        cane.canefile = ".cane"
        cane.add_threshold 'coverage/covered_percent', :>=, 100
      end

      task :default => :quality
    rescue LoadError
      warn "cane not available, quality task not provided."
    end
  end
end
