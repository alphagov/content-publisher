desc "Run Brakeman"
task brakeman: :environment do
  sh "brakeman -q"
end
