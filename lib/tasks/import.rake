# frozen_string_literal: true

namespace :import do
  desc "Import all documents matching an organisation and document type from Whitehall Publisher, e.g. import:whitehall_migration[\"cabinet-office\",\"NewsArticle\"]"
  task :whitehall_migration, %i[organisation_slug document_type] => :environment do |_, args|
    ActiveRecord::Base.transaction do
      organisation_content_id = GdsApi.publishing_api.lookup_content_id(
        base_path: "/government/organisations/#{args.organisation_slug}",
      )

      whitehall_migration = WhitehallImporter.create_migration(organisation_content_id, args.document_type)

      documents_to_import = WhitehallMigration::DocumentImport.where(whitehall_migration_id: whitehall_migration.id).count
      puts "Identified #{documents_to_import} documents to import"
    end
  end

  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall_document[123]"
  task :whitehall_document, [:document_id] => :environment do |_, args|
    whitehall_migration_document_import = WhitehallMigration::DocumentImport.create(
      whitehall_document_id: args.document_id,
      state: "pending"
    )
    whitehall_import = WhitehallImporter.import_and_sync(whitehall_migration_document_import)

    unless whitehall_import.completed?
      puts whitehall_import.state.humanize
      puts "Error: #{whitehall_import.error_log}"
      abort
    end
  end
end
