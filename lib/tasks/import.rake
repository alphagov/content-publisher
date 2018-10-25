# frozen_string_literal: true

require "tasks/whitehall_news_importer"

namespace :import do
  desc "Import news documents from JSON e.g. import:whitehall_news INPUT=export_file"
  task whitehall_news: :environment do
    importer = Tasks::WhitehallNewsImporter.new
    imported = 0

    input = ENV["INPUT"] ? File.open(ENV["INPUT"]) : STDIN

    input.each_line do |line|
      next if line.include?("government_response")
      next if line.include?("world_news_story")

      importer.import(JSON.parse(line))
      imported += 1
      puts "Imported #{imported} documents" if (imported % 500).zero?
    end

    puts "Completed importing #{imported} Whitehall news documents"
  end
end
