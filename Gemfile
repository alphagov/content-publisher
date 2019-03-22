# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 5.2"

gem "aws-sdk-s3", "~> 1"
gem "bootsnap", "~> 1"
gem "gds-api-adapters", "~> 57.5.0"
gem "gds-sso", "~> 14"
gem "govspeak", "~> 6"
gem "govuk_app_config", "~> 1"
gem "govuk_publishing_components", "~> 16.7"
gem "govuk_sidekiq", "~> 3"
gem "hashdiff", "~> 0.3"
gem "image_processing", "~> 1"
gem "kaminari", "~> 1"
gem "notifications-ruby-client", "~> 3.1"
gem "pg", "~> 1"
gem "plek", "~> 2"
gem "rinku", "~> 2"
gem "uglifier", "~> 4"

group :development do
  gem "brakeman", "~> 4"
  gem "foreman", "~> 0.85"
  gem "listen", "~> 3"
end

group :test do
  gem "rspec-sidekiq", "~> 3"
  gem "simplecov", "~> 0.16"
end

group :development, :test do
  gem "byebug", "~> 11"
  # Using this fork until https://github.com/dbalatero/capybara-chromedriver-logger/issues/6
  # is resolved and released
  gem "capybara-chromedriver-logger", git: "https://github.com/ThriveTRM/capybara-chromedriver-logger", ref: "77b9c9a"
  gem "climate_control"
  gem "factory_bot_rails", "~> 5"
  gem "govuk-lint", "~> 3"
  gem "govuk_schemas", "~> 3.2"
  gem "govuk_test", "~> 0.3"
  gem "jasmine", "~> 3.3"
  gem "jasmine_selenium_runner", "~> 3", require: false
  gem "rspec-rails", "~> 3"
  gem "webmock", "~> 3"
end
