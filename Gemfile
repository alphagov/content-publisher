# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 5.2"

gem "bootsnap", "~> 1"
gem "gds-api-adapters", "~> 52"
gem "gds-sso", "~> 13"
gem "govuk_app_config", "~> 1"
gem "govuk_publishing_components", "~> 9.5"
gem "pg", "~> 1"
gem "plek", "~> 2"
gem "uglifier", "~> 4"
gem "paper_trail", "~> 9.2"

group :development do
  gem "listen", "~> 3"
end

group :test do
  gem "simplecov", "~> 0.16"
end

group :development, :test do
  gem "byebug", "~> 10"
  gem "capybara"
  gem "govuk-lint", "~> 3"
  gem "rspec-rails", "~> 3"
end
