# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 5.2"

gem "aws-sdk-s3", "~> 1"
gem "bootsnap", "~> 1"
gem "gds-api-adapters", "~> 59"
gem "gds-sso", "~> 14"
gem "govspeak", "~> 6.2"
gem "govuk_app_config", "~> 1"
gem "govuk_publishing_components", "~> 17.1"
gem "govuk_sidekiq", "~> 3"
gem "hashdiff", "~> 0.4"
gem "image_processing", "~> 1"
gem "interactor", "~> 3"
gem "kaminari", "~> 1"
gem "notifications-ruby-client", "~> 3.1"
gem "pdf-reader", "~> 2"
gem "pg", "~> 1"
gem "plek", "~> 3"
gem "rinku", "~> 2"
gem "rubyzip", "~> 1", require: "zip"
gem "uglifier", "~> 4"

group :development do
  gem "brakeman", "~> 4"
  gem "listen", "~> 3"
end

group :test do
  gem "simplecov", "~> 0.16"
end

group :development, :test do
  gem "byebug", "~> 11"
  gem "climate_control"
  gem "factory_bot_rails", "~> 5"
  gem "govuk-lint", "~> 3"
  gem "govuk_schemas", "~> 3.2"
  gem "govuk_test", "~> 0.5"
  gem "jasmine", "~> 3.4"
  gem "jasmine_selenium_runner", "~> 3", require: false
  gem "rspec-rails", "~> 3"
  gem "webmock", "~> 3"
end
