# frozen_string_literal: true

desc "Run FactoryBot linter"
namespace :factorybot do
  task lint: :environment do
    if Rails.env.test?
      ActiveRecord::Base.transaction do
        FactoryBot.lint(traits: true)
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factorybot:lint RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end
end
