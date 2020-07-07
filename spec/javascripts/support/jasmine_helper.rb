require "jasmine_selenium_runner/configure_jasmine"

class ChromeHeadlessJasmineConfigurer < JasmineSeleniumRunner::ConfigureJasmine
  def selenium_options
    chrome_options = Selenium::WebDriver::Chrome::Options.new
    chrome_options.headless!
    { options: chrome_options }
  end
end
