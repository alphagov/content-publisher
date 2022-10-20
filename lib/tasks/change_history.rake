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

  desc "Delete a single change note for a document, e.g. change_history:delete[content_id change-note-id]"
  task :delete, %i[content_id change_history_id] => :environment do |_, args|
    EditionUpdater.call(args.content_id,
                        locale: ENV.fetch("LOCALE", "en"),
                        user_email: ENV["USER_EMAIL"]) do |edition, updater|
      entry = edition.change_history.find { |item| item["id"] == args.change_history_id }
      raise "No change history entry with id #{args.change_history_id}" unless entry

      updater.assign(change_history: edition.change_history - [entry])
    end
  end

  desc "Edit a single change note for a document, e.g. change_history:edit[content-id, change-note-id] NOTE='some note'"
  task :edit, %i[content_id change_history_id] => :environment do |_, args|
    EditionUpdater.call(args.content_id,
                        locale: ENV.fetch("LOCALE", "en"),
                        user_email: ENV["USER_EMAIL"]) do |edition, updater|
      raise "Expected a note" if ENV["NOTE"].blank?

      change_history = edition.change_history.deep_dup
      entry = change_history.find { |item| item["id"] == args.change_history_id }
      raise "No change history entry with id #{args.change_history_id}" unless entry

      entry["note"] = ENV["NOTE"]
      updater.assign(change_history:)
    end
  end

  desc "Add a new change note for a document, e.g. change_history:add[content-id] NOTE='some note' TIMESTAMP='2020-01-01 10:30:00'"
  task :add, %i[content_id] => :environment do |_, args|
    EditionUpdater.call(args.content_id,
                        locale: ENV.fetch("LOCALE", "en"),
                        user_email: ENV["USER_EMAIL"]) do |edition, updater|
      raise "Expected a note" if ENV["NOTE"].blank?
      raise "Expected a timestamp" if ENV["TIMESTAMP"].blank?

      entry = {
        "id" => SecureRandom.uuid,
        "note" => ENV["NOTE"],
        "public_timestamp" => Time.zone.parse(ENV["TIMESTAMP"]).rfc3339,
      }

      change_history = (edition.change_history + [entry])
        .sort_by { |note| note["public_timestamp"] }
        .reverse

      updater.assign(change_history:)
    end
  end
end
