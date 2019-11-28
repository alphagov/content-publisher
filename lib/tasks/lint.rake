# frozen_string_literal: true

desc "lint Ruby, FactoryBot, Sass and Javascript"
task lint: :environment do
  sh "bundle exec rubocop --format clang"
  sh "bundle exec rake factorybot:lint RAILS_ENV='test'"
  sh "bundle exec scss-lint app/assets/stylesheets"
  sh "yarn run lint"
end
