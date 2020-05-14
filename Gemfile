ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails"

gem "aws-sdk-s3", "~> 1.64.0"
gem "bootsnap", "~> 1.4.0"
gem "gds-api-adapters"
gem "gds-sso"
gem "govspeak"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "hashdiff", "~> 1.0.0"
gem "image_processing", "~> 1.10.0"
gem "interactor", "~> 3.1.0"
gem "kaminari", "~> 1.2.0"
gem "mail-notify", "~> 1.0.2"
gem "pdf-reader", "~> 2.4.0"
gem "pg"
gem "plek"
gem "rinku", "~> 2.0.0"
gem "rubyzip", "~> 2.3.0", require: "zip"
gem "sanitize", "~> 5.1.0"
gem "sass-rails", "< 6"
gem "sidekiq-scheduler", "~> 3.0.0"
gem "uglifier", "~> 4.2.0"
gem "with_advisory_lock", "~> 4.6.0"

group :development do
  gem "brakeman"
  gem "listen", "~> 3.2.0"
end

group :test do
  gem "simplecov", "~> 0.18.0"
end

group :development, :test do
  gem "byebug", "~> 11.1.0"
  gem "climate_control", "~> 0.2.0"
  gem "factory_bot_rails", "~> 5.2.0"
  gem "govuk_schemas"
  gem "govuk_test"
  gem "jasmine", "~> 3.5.0"
  gem "jasmine_selenium_runner", "~> 3.0.0", require: false
  gem "json_matchers", "~> 0.11.0"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "scss_lint-govuk"
  gem "webmock", "~> 3.8.0"
end
