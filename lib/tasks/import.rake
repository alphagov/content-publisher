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

    documents_to_import = WhitehallMigration::DocumentImport.where(whitehall_migration:).count
    puts "Identified #{documents_to_import} documents to import"

    url_helpers = Rails.application.routes.url_helpers
    puts url_helpers.whitehall_migration_url(whitehall_migration, host: Plek.external_url_for("content-publisher"))
  end

  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall_document[123]"
  task :whitehall_document, [:document_id] => :environment do |_, args|
    whitehall_import = WhitehallMigration::DocumentImport.create!(
      whitehall_document_id: args.document_id,
      whitehall_migration: WhitehallMigration.create!,
      state: "pending",
    )

    WhitehallDocumentImportJob.perform_later(whitehall_import)
    puts "Added whitehall document with ID:#{args.document_id} to the import queue"

    url_helpers = Rails.application.routes.url_helpers
    puts url_helpers.whitehall_migration_url(whitehall_import.whitehall_migration_id, host: Plek.external_url_for("content-publisher"))
  end

  desc "Import multiple documents from Whitehall Publisher using Whitehall's internal document ID's e.g. import:whitehall_documents[\"123 456 789\"]"
  task :whitehall_documents, [:document_ids] => :environment do |_, args|
    whitehall_migration = WhitehallMigration.create!

    args.document_ids.split(" ").map(&:to_i).each do |document_id|
      whitehall_import = WhitehallMigration::DocumentImport.create!(
        whitehall_document_id: document_id,
        whitehall_migration:,
        state: "pending",
      )

      WhitehallDocumentImportJob.perform_later(whitehall_import)
      puts "Added whitehall document with ID:#{document_id} to the import queue"
    end

    url_helpers = Rails.application.routes.url_helpers
    puts url_helpers.whitehall_migration_url(whitehall_migration.id, host: Plek.external_url_for("content-publisher"))
  end
end
