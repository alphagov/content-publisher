# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

require "byebug"
require "govuk_schemas/rspec_matchers"
require "simplecov"
require "webmock/rspec"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/publishing_api_v2"
require "gds_api/test_helpers/asset_manager"
require "govuk_sidekiq/testing"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
SimpleCov.start
GovukTest.configure
I18nCov.start
WebMock.disable_net_connect!(allow_localhost: true)
Capybara.automatic_label_click = true
ActiveRecord::Migration.maintain_test_schema!
Rails.application.load_tasks
Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include GdsApi::TestHelpers::PublishingApi
  config.include GdsApi::TestHelpers::PublishingApiV2
  config.include GdsApi::TestHelpers::AssetManager
  config.include GovukSchemas::RSpecMatchers
  config.include AuthenticationHelper, type: :feature

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before :suite do
    Rails.application.load_seed
  end

  config.before :each, type: :feature do
    # This is required by lots of specs when visiting the index page
    stub_publishing_api_has_linkables([], document_type: "organisation")
  end

  config.before :each do
    Sidekiq::Worker.clear_all
    ActionMailer::Base.deliveries.clear
  end

  config.after :each, type: :feature do
    reset_authentication
  end
end
