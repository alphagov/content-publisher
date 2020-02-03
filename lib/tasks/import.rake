# frozen_string_literal: true

require "gds_api/whitehall_export"

namespace :import do
  desc "Import all documents matching an organisation, document type and optional list of document subtypes from Whitehall Publisher, e.g. import:whitehall_migration[\"cabinet-office\",\"news_article\",\"news_story,press_release\"]"
  task :whitehall_migration, %i[organisation_slug document_type document_subtypes] => :environment do |_, args|
    organisation_content_id = GdsApi.publishing_api.lookup_content_id(
      base_path: "/government/organisations/#{args.organisation_slug}",
    )
    document_subtypes = args.document_subtypes ? args.document_subtypes.split(",") : []
    whitehall_migration = WhitehallImporter::CreateMigration.call(
      organisation_content_id, args.document_type, document_subtypes
    )

    documents_to_import = WhitehallMigration::DocumentImport.where(whitehall_migration_id: whitehall_migration.id).count
    puts "Identified #{documents_to_import} documents to import"
  end

  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall_document[123]"
  task :whitehall_document, [:document_id] => :environment do |_, args|
    whitehall_import = WhitehallMigration::DocumentImport.create!(
      whitehall_document_id: args.document_id,
      state: "pending",
    )
    WhitehallImporter.import_and_sync(whitehall_import)

    unless whitehall_import.completed?
      puts whitehall_import.state.humanize
      puts "Error: #{whitehall_import.error_log}"
      abort
    end
  end
end
