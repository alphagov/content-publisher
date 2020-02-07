# frozen_string_literal: true

require "gds_api/whitehall_export"

module WhitehallImporter
  class CreateMigration
    attr_reader :organisation_content_id, :document_type, :document_subtypes

    def self.call(*args)
      new(*args).call
    end

    def initialize(organisation_content_id, document_type, document_subtypes = [])
      @organisation_content_id = organisation_content_id
      @document_type = document_type
      @document_subtypes = document_subtypes
    end

    def call
      whitehall_migration = ActiveRecord::Base.transaction do
        record = create_migration
        whitehall_document_list.each { |page| create_document_imports(page, record) }
        record
      end
      whitehall_migration.document_imports.find_each do |document_import|
        WhitehallDocumentImportJob.perform_later(document_import)
      end
      whitehall_migration
    end

  private

    def create_migration
      WhitehallMigration.create!(organisation_content_id: organisation_content_id,
                                 document_type: document_type,
                                 document_subtypes: document_subtypes)
    end

    def whitehall_document_list
      GdsApi.whitehall_export.document_list(organisation_content_id,
                                            document_type,
                                            document_subtypes)
    end

    def create_document_imports(page, record)
      page["documents"].each do |document|
        record.document_imports.create!(
          whitehall_document_id: document["document_id"],
          state: "pending",
        )
      end
    end
  end
end
