require "simplecov"
puts "[Simplecov] Loaded."

class SimpleCov::Formatter::QualityFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    File.open("coverage/covered_percent", "w") do |f|
      f.puts result.source_files.covered_percent.to_f
    end
  end
end

SimpleCov.merge_timeout 1800 #30 mins
if suite_name = ENV["COVERAGE_GROUP"]
  SimpleCov.command_name(suite_name)
end
SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter
SimpleCov.start do
  add_filter "/vendor/"
  if ENV["CHECK_SPEC_COVERAGE"] == "true"
    # Check all specs for full coverage across browsers
    add_filter "/spec/dummy" #Ignore dummy rails app
    add_filter "/spec/support/selenium_display" #Multi browser helper
  else
    # Ignore all spec coverage
    add_filter "/spec/"
  end
end


