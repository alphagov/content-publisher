# frozen_string_literal: true

desc "Run Brakeman"
task brakeman: :environment do
  sh "brakeman -q"
end
