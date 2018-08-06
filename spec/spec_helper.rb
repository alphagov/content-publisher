# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

require "byebug"
require "govuk_schemas/rspec_matchers"
require "simplecov"
require "webmock/rspec"
require "gds_api/test_helpers/publishing_api_v2"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }
SimpleCov.start
GovukTest.configure
WebMock.disable_net_connect!(allow_localhost: true)
Capybara.automatic_label_click = true
Capybara::Chromedriver::Logger.raise_js_errors = true

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include GdsApi::TestHelpers::PublishingApiV2
  config.include GovukSchemas::RSpecMatchers

  config.before(:suite) do
    User.create!(permissions: ["signin"])
  end

  config.after :each, type: :feature, js: true do
    Capybara::Chromedriver::Logger::TestHooks.after_example!
  end
end
