require 'selenium-webdriver'

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

    print_debug_info if ENV['SELENIUM_DEBUG']
  end

  private

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
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.ie
      self.browser_capability.version = (browser.match /ie(?<version>\d+)/)[:version]
      self.browser_capability.platform = "windows"
      self.browser = 'ie'
    when 'chrome'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.chrome

    when 'ipad'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.ipad
      self.resizable = false
    when 'iphone'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.iphone
      self.resizable = false
    when 'firefox'
      self.browser_capability = Selenium::WebDriver::Remote::Capabilities.firefox
      profile = Selenium::WebDriver::Firefox::Profile.new
      # disable autoupdate on load of firefox
      profile['extensions.update.enabled'] = false
      profile['app.update.auto'] = false
      profile['app.update.enabled'] = false
      self.selenium_options.merge!({:profile => profile })
    else
      raise "Error - Unsupported browser format '#{browser}'"
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
