ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "5.2.0"
gem "bootsnap"

gem "database_cleaner"
gem "deprecated_columns"
gem "gds-sso"
gem "plek"
gem "govuk_app_config"
gem "sass-rails"
gem "uglifier"
gem "gds-api-adapters"
gem "govuk_sidekiq"
group :development, :test do
  gem "poltergeist"
  gem "capybara"
  gem "pry"
  gem "simplecov-rcov", require: false
  gem "simplecov", require: false
  gem "govuk-lint"
  gem "sqlite3" # Remove this when you choose a production database
  gem "factory_bot_rails"
  gem "timecop"
  gem "webmock", require: false
  gem "rspec-rails"
  gem "byebug" # Comes standard with Rails
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
  gem "listen"
end
