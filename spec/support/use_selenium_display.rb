# Use selenium display
require 'support/selenium_display'
require 'capybara'

$selenium_display = SeleniumDisplay.new

Capybara.register_driver :selenium_browser do |app|
  Capybara::Selenium::Driver.new(app, $selenium_display.selenium_options).tap do |driver|
    driver.browser.manage.window.size = $selenium_display.device if $selenium_display.resizable
  end
end

Capybara.javascript_driver = :selenium_browser
Capybara.default_wait_time = 10

