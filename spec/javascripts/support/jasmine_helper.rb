require "jasmine_selenium_runner/configure_jasmine"

class ChromeHeadlessJasmineConfigurer < JasmineSeleniumRunner::ConfigureJasmine
  def selenium_options
    { options: GovukTest.chrome_selenium_options }
  end
end
