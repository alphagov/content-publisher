# frozen_string_literal: true

require "gds_api/whitehall_export"

namespace :import do
  desc "Import all documents matching an organisation and document type from Whitehall Publisher, e.g. import:whitehall_migration[organisation-slug, document-type]"
  task :whitehall_migration, %i[organisation_slug document_type] => :environment do |_, args|
    whitehall_migration = WhitehallImporter.create_migration(args.organisation_slug, args.document_type)

    documents_to_import = WhitehallMigration::DocumentImport.where(whitehall_migration_id: whitehall_migration.id).count
    puts "Identified #{documents_to_import} documents to import"
  end

  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall_document[123]"
  task :whitehall_document, [:document_id] => :environment do |_, args|
    whitehall_export = GdsApi.whitehall_export.document_export(args.document_id)
    whitehall_import = WhitehallImporter.import_and_sync(whitehall_export.to_hash)

    unless whitehall_import.completed?
      puts whitehall_import.state.humanize
      puts "Error: #{whitehall_import.error_log}"
      abort
    end
  end
end
