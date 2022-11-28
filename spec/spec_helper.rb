ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

# Must go at top of file
require "simplecov"
SimpleCov.start "rails"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

require "byebug"
require "govuk_schemas/rspec_matchers"
require "webmock/rspec"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/asset_manager"
require "govuk_sidekiq/testing"
require "json_matchers/rspec"
require "i18n/coverage/printers/file_printer"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
GovukTest.configure
WebMock.disable_net_connect!(allow_localhost: true)
Capybara.automatic_label_click = true
ActiveRecord::Migration.maintain_test_schema!
Rails.application.load_tasks
Sidekiq::Testing.fake!
JsonMatchers.schema_root = "spec/support/schemas"
I18n::Coverage.config.printer = I18n::Coverage::Printers::FilePrinter

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.fixture_path = Rails.root.join("/spec/fixtures")
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods
  config.include GdsApi::TestHelpers::PublishingApi
  config.include GdsApi::TestHelpers::AssetManager
  config.include GovukSchemas::RSpecMatchers
  config.include AuthenticationHelper, type: ->(spec) { spec.in?(%i[feature request view]) }
  config.include BulkDataHelper
  config.include Capybara::RSpecMatchers, type: :request

  unless config.files_to_run.one?
    I18n::Coverage.start
  end

  config.before :suite do
    Rails.application.load_seed
  end

  config.before :all do
    DocumentType.clear
  end

  config.before do
    Sidekiq::Worker.clear_all
    ActionMailer::Base.deliveries.clear
    BulkData::Cache.clear
  end

  config.before :each, type: :feature do
    # This is required by lots of specs when visiting the index page
    stub_publishing_api_has_linkables([], document_type: "organisation")
  end

  config.before :each, type: ->(spec) { spec.in?(%i[feature request]) } do
    populate_default_government_bulk_data
  end

  config.after :each, type: ->(spec) { spec.in?(%i[feature request view]) } do
    reset_authentication
  end

  config.before :each, type: :view do
    allow(view).to receive(:current_user) { current_user }
    allow(view).to receive(:rendering_context).and_return("application")

    def described_template
      self.class.top_level_description
    end
  end
end
