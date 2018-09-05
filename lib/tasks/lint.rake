# frozen_string_literal: true

desc "lint Ruby, Sass and Javascript"
task "lint" do
  sh "govuk-lint-ruby --format clang"
  sh "govuk-lint-sass app/assets/stylesheets"
  sh "yarn run lint"
end
