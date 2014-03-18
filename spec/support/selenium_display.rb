require "selenium/webdriver"
require 'selenium/webdriver/remote/http/persistent'
require "sauce/config"
require "sauce/connect"

Device = Struct.new(:width, :height)

class SeleniumDisplay
  attr_accessor :browser, :device, :device_name,
                :resizable, :browser_capability,
                :selenium_options

  def initialize(overrides = {})
    #Browser options
    self.browser    = (ENV['BROWSER'] || 'firefox').strip.downcase
    self.resizable  = true #Check compatibility with all devices

    self.selenium_options = { :browser => self.browser.to_sym }

    define_browser_capability

    self.device_name = ENV['DEVICE'] || 'desktop'
    self.device = define_device(device_name)

    set_travis_options! if running_on_travis?
    set_sauce_options!  if use_sauce?

    print_debug_info if ENV['SELENIUM_DEBUG']
  end

  private

  def running_on_travis?
    !ENV['TRAVIS_JOB_NUMBER'].nil?
  end

  def use_sauce?
    !ENV['USE_SAUCE'].nil?
  end

  def define_device device_type
    case device_type.strip.downcase
    when 'phone'
      Device.new(320, 480) #IPhone dimensions
    when 'tablet'
      Device.new(1024, 768)
    when 'desktop'
      Device.new(1400, 900)
    when 'cinema-desktop'
      Device.new(2560, 1440)
    else
      raise "Error - Unsupported device type '#{device_type}'"
    end
  end

  def define_browser_capability
    case browser
    when /ie\d+/
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.internet_explorer
      version_number          = (browser.match /ie(?<version>\d+)/)[:version]

      self.browser_capability.platform = version_number.to_i <= 8 ? "Windows XP" : "Windows 7"
      self.browser_capability.version = version_number
      self.browser = 'Internet Explorer'
    when 'chrome'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.chrome
    when 'ipad'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.ipad
      self.resizable = false
    when 'iphone'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.iphone
      self.browser_capability.platform = "OS X 10.9" #Sauce labs
      self.browser_capability.version = "7"
      self.browser_capability['device-orientation'] = 'portrait'

      self.resizable = false
    when 'firefox'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.firefox
      profile = Selenium::WebDriver::Firefox::Profile.new
      # disable autoupdate on load of firefox
      profile['extensions.update.enabled'] = false
      profile['app.update.auto'] = false
      profile['app.update.enabled'] = false
      self.selenium_options.merge!(profile: profile)
    when 'android'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.android
    when 'safari'
      # Sauce labs
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.safari
      self.browser_capability.platform = "OS X 10.9"
      self.browser_capability.version = "7"
    else
      raise "Error - Unsupported browser format '#{browser}'"
    end
  end

  def set_travis_options!
    self.browser_capability["build"] = ENV["TRAVIS_BUILD_NUMBER"]
  end

  def set_sauce_options!
    raise_on_missing_sauce_variables! unless running_on_travis?

    sauce_config = Sauce::Config.new
    host = sauce_config[:application_host] || "127.0.0.1"
    port = sauce_config[:application_port]

    Capybara.server_port        = port
    Capybara.app_host           = "http://#{host}:#{port}"
    Capybara.default_wait_time  = 30

    client = ::Selenium::WebDriver::Remote::Http::Persistent.new
    client.timeout = 300

    if running_on_travis?
      # Running on Travis CI (use existing tunnel)
      self.browser_capability["tunnel-identifier"] = ENV["TRAVIS_JOB_NUMBER"]
    else
      # Connect local tunnel (and wait for connection)
      Sauce::Connect.connect!
    end

    self.selenium_options.delete(:profile) #Incompatible

    url = "http://#{sauce_config.username}:#{sauce_config.access_key}@#{sauce_config.host}:#{sauce_config.port}/wd/hub"
    #client_version => Unnecessary, chooses latest
    #platform => allow browser capability to set (default: linux)
    self.browser_capability.merge!(
      name: sauce_job_name,
      browserName: browser
    )
    self.selenium_options.merge!(
      browser: :remote,
      url: url,
      desired_capabilities: self.browser_capability,
      http_client: client
    )

    set_build_to_notify_sauce!
  end

  def sauce_job_name
    [ENV['TRAVIS_JOB_NUMBER'], browser, device_name].compact.join(" : ")
  end

  def raise_on_missing_sauce_variables!
    # Required sauce variables
    %w( SAUCE_USERNAME SAUCE_ACCESS_KEY ).each do |env_var|
      raise "Error - set #{env_var} for access to open-sauce for selenium tests" unless ENV[env_var]
    end
  end

  def set_build_to_notify_sauce!
    # Notify sauce labs of build result if any specs were:
    #  * JS related (browser specs)
    RSpec.configure do |config|
      config.after(:suite) do
        examples      = RSpec.world.filtered_examples.values.flatten
        sauce_results = examples.inject({}) do |result, example|
          result      ||= {passed: [], failed: [], total: 0}
          next unless example.metadata.include?(:js) #only js features

          result[:total] += 1
          key = example.exception.nil? ? :passed : :failed
          result[key] << example
          result
        end

        if sauce_results[:total] > 0
          job_result = sauce_results[:failed].count > 0 ? "failed" : "passed"
          Capybara.using_driver(:selenium_browser) do
            Capybara.current_session.driver.execute_script("sauce:job-result=#{job_result}")
          end
        end
      end
    end
  end

  def print_debug_info
    STDERR.puts " >> Loading Selenium display"
    STDERR.puts "   ->> browser     : #{browser}"
    STDERR.puts "   ->> device type : #{device_name}"
    STDERR.puts "   ->> device      : #{device}"
    STDERR.puts "   ->> options     : #{selenium_options}"
  end
end
