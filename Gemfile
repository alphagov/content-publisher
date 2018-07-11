ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "rails", "~> 5.2"

gem "bootsnap", "~> 1"
gem "gds-sso", "~> 13"
gem "govuk_app_config", "~> 1"
gem "pg", "~> 1"
gem "plek", "~> 2"

group :development do
  gem "listen"
end

group :test do
  gem "simplecov", require: false
end

group :development, :test do
  gem "byebug"
  gem "rspec-rails"
  gem "govuk-lint"
end
