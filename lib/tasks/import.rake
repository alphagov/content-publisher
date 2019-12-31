# frozen_string_literal: true

namespace :import do
  desc "Import all documents matching an organisation and document type from Whitehall Publisher, e.g. import:whitehall_migration[organisation-slug, document-type]"
  task :whitehall_migration, %i[organisation_slug document_type] => :environment do |_, args|
    WhitehallMigration.create!(organisation_slug: args.organisation_slug,
                               document_type: args.document_type,
                               start_time: Time.zone.now)
  end

  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall_document[123]"
  task :whitehall_document, [:document_id] => :environment do |_, args|
    whitehall_export = Services.whitehall.document_export(args.document_id)
    whitehall_import = WhitehallImporter.import_and_sync(whitehall_export)

    unless whitehall_import.completed?
      puts whitehall_import.state.humanize
      puts "Error: #{whitehall_import.error_log}"
      abort
    end
  end
end
