# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../config/environment", __dir__)
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
ActiveRecord::Migration.maintain_test_schema!

Capybara.server = :puma, { Silent: true }
Capybara::Chromedriver::Logger.raise_js_errors = true
Capybara::Chromedriver::Logger.filters = [
  /the server responded with a status of 409/i,
]

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include GdsApi::TestHelpers::PublishingApiV2
  config.include GovukSchemas::RSpecMatchers
  config.include ReadableButtonsHelper

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before :suite do
    Rails.application.load_seed
  end

  config.before :each, format: true do
    publishing_api_has_linkables([{ "content_id" => User.first.organisation_content_id, "internal_name" => "Linkable" }], document_type: "organisation")
  end

  config.after :each, type: :feature, js: true do
    Capybara::Chromedriver::Logger::TestHooks.after_example!
  end

  config.before :each, type: :controller do
    request.env["warden"] = double(
      authenticate!: true,
      authenticated?: true,
      user: User.first,
    )
  end
end
