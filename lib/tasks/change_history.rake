namespace :change_history do
  desc "Show all change notes for a document"
  task :show, %i[content_id] => :environment do |_, args|
    Edition
      .find_current(document: "#{args.content_id}:#{ENV.fetch('LOCALE', 'en')}")
      .change_history
      .each do |entry|
      puts [entry["id"], entry["public_timestamp"], entry["note"]].join(" | ")
    end
  end
end
