# frozen_string_literal: true

namespace :resync do
  desc "Resync a document with the publishing-api e.g. resync:document['a-content-id:en']"
  task :document, [:content_id_and_locale] => :environment do |_, args|
    raise "Missing content_id and locale parameter" unless args.content_id_and_locale

    document = Document.find_by_param(args.content_id_and_locale)

    raise "No document exists for #{content_id_and_locale}" unless document

    ResyncService.call(document)
  end

  desc "Resync all documents with the publishing-api e.g. resync:all"
  task all: :environment do
    Document.find_each do |document|
      ResyncService.call(document)
    end
  end
end
