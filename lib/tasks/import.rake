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

    begin
      whitehall_import = WhitehallImporter::Import.call(whitehall_import)
      whitehall_import = WhitehallImporter::Sync.call(whitehall_import)
    rescue StandardError => e
      case e
      when WhitehallImporter::IntegrityCheckError
        whitehall_import.update!(
          error_log: e.inspect,
          state: "import_aborted",
          integrity_check_problems: e.problems,
          integrity_check_proposed_payload: e.payload,
        )
      when WhitehallImporter::AbortImportError
        whitehall_import.update!(state: "import_aborted", error_log: e.inspect)
      else
        state = whitehall_import.imported? ? "sync_failed" : "import_failed"
        whitehall_import.update!(state: state, error_log: e.inspect)
      end

      puts whitehall_import.state.humanize
      puts "Error: #{whitehall_import.error_log}"
      abort
    end
  end
end
