# frozen_string_literal: true

desc "lint Ruby, FactoryBot, Sass and Javascript"
task "lint" do
  sh "govuk-lint-ruby --format clang"
  sh "bundle exec rake factorybot:lint RAILS_ENV='test'"
  sh "govuk-lint-sass app/assets/stylesheets"
  sh "yarn run lint"
end
