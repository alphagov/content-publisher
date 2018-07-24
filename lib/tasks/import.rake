# frozen_string_literal: true

require "tasks/whitehall_news_importer"

namespace :import do
  task :whitehall_news, [:path] => :environment do |_t, args|
    to_import = JSON.parse(File.read(args[:path]))
    done = Tasks::WhitehallNewsImporter.new(to_import).import
    puts "Imported #{done} Whitehall news documents"
  end
end
