desc "lint Ruby, FactoryBot, Sass and Javascript"
task lint: :environment do
  sh "bundle exec rubocop --format clang"
  sh "bundle exec rake factorybot:lint RAILS_ENV='test'"
  sh "yarn run lint"
end
