# frozen_string_literal: true

class RepopulateDocumentIdInMetadataRevisions < ActiveRecord::Migration[5.2]
  def up
    type_doc_ids_hash = Document.group(:document_type_id).pluck(:document_type_id, "ARRAY_AGG(id)").to_h

    type_doc_ids_hash.each do |type, ids|
      MetadataRevision.joins("INNER JOIN revisions ON metadata_revisions.id = revisions.metadata_revision_id")
        .where("revisions.document_id": ids).update_all(document_type_id: type)
    end
  end
end
