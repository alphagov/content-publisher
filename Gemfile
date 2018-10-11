# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 5.2"

gem "aws-sdk-s3", "~> 1"
gem "bootsnap", "~> 1"
gem "gds-api-adapters", "~> 53"
gem "gds-sso", "~> 13"
gem "govspeak", "~> 5"
gem "govuk_app_config", "~> 1"
gem "govuk_publishing_components", path: "../govuk_publishing_components"
gem "image_processing", "~> 1"
gem "kaminari", "~> 1"
gem "paper_trail", "~> 10.0"
gem "pg", "~> 1"
gem "plek", "~> 2"
gem "uglifier", "~> 4"

group :development do
  gem "brakeman", "~> 4"
  gem "foreman", "~> 0.85"
  gem "listen", "~> 3"
end

group :test do
  gem "simplecov", "~> 0.16"
end

group :development, :test do
  gem "byebug", "~> 10"
  gem "capybara-chromedriver-logger"
  gem "factory_bot_rails", "~> 4"
  gem "govuk-lint", "~> 3"
  gem "govuk_schemas", "~> 3.2"
  gem "govuk_test", "~> 0.2"
  gem "jasmine", "~> 2.4"
  gem "rspec-rails", "~> 3"
  gem "webmock", "~> 3"
end
