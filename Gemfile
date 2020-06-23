ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 6.0"

gem "aws-sdk-s3", "~> 1"
gem "bootsnap", "~> 1"
gem "gds-api-adapters", "~> 67"
gem "gds-sso", "~> 15"
gem "govspeak", "~> 6.5"
gem "govuk_app_config", "~> 2"
gem "govuk_publishing_components", "~> 21"
gem "govuk_sidekiq", "~> 3"
gem "hashdiff", "~> 1.0"
gem "image_processing", "~> 1"
gem "interactor", "~> 3"
gem "kaminari", "~> 1"
gem "mail-notify", "~> 1"
gem "pdf-reader", "~> 2"
gem "pg", "~> 1"
gem "plek", "~> 4"
gem "rinku", "~> 2"
gem "rubyzip", "~> 2", require: "zip"
gem "sanitize", "~> 5"
gem "sass-rails", "< 6"
gem "sidekiq-scheduler", "~> 3"
gem "uglifier", "~> 4"
gem "with_advisory_lock", "~> 4"

group :development do
  gem "brakeman", "~> 4"
  gem "listen", "~> 3"
end

group :test do
  gem "simplecov", "~> 0.18"
end

group :development, :test do
  gem "byebug", "~> 11"
  gem "climate_control"
  gem "factory_bot_rails", "~> 6"
  gem "govuk_schemas", "~> 4.0"
  gem "govuk_test", "~> 1.0"
  gem "jasmine", "~> 3"
  gem "jasmine_selenium_runner", "~> 3", require: false
  gem "json_matchers"
  gem "rspec-rails", "~> 4"
  gem "rubocop-govuk", "~> 3"
  gem "scss_lint-govuk", "~> 0"
  gem "webmock", "~> 3"
end
