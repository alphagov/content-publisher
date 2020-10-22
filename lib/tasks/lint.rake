desc "lint Ruby, FactoryBot, Sass and Javascript"
task lint: :environment do
  sh "bundle exec rubocop"
  sh "yarn run lint"
  sh "bundle exec rake factorybot:lint RAILS_ENV='test'"
end
