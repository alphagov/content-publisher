# frozen_string_literal: true

desc "Run govuk-lint on all files"
task "lint" do
  sh "govuk-lint-ruby --format clang --rails"
  sh "govuk-lint-sass app/assets/stylesheets"
  sh "npm run lint --silent"
end
