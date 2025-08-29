class WhitehallMigration::DocumentExport
  def self.exportable_documents
    @exportable_documents ||= Document
      .includes(:live_edition)
      .select do |document|
        document.live_edition && document.live_edition.state != "removed"
      end
  end

  def self.export_to_hash(document)
    content_revision = document.live_edition.revision.content_revision

    {
      content_id: document[:content_id],
      state: document.live_edition.state,
      created_at: document[:created_at],
      first_published_at: document[:first_published_at],
      updated_at: document[:updated_at],
      created_by: User.find(document.created_by_id).email,
      last_edited_by: User.find(document.live_edition.revision.created_by_id).email,
      document_type: document.live_edition.revision.metadata_revision.document_type_id,
      title: content_revision.title,
      base_path: content_revision.base_path,
      summary: content_revision.summary,
      body: content_revision.contents["body"],
      tags: document.live_edition.revision.tags_revision.tags,
    }
  end
end
