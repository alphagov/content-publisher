namespace :factorybot do
  desc "Run FactoryBot linter"
  task lint: :environment do
    if Rails.env.test?
      ActiveRecord::Base.transaction do
        FactoryBot.lint(traits: true)
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factorybot:lint RAILS_ENV='test'")
      raise if $CHILD_STATUS.exitstatus.nonzero?
    end
  end
end
