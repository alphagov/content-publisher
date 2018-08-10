# frozen_string_literal: true

desc "Run Brakeman"
task :brakeman do
  sh "brakeman -q"
end
