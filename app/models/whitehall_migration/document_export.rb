class WhitehallMigration::DocumentExport
  def self.exportable_documents
    @exportable_documents ||= Document
      .includes(:live_edition)
      .select do |document|
        document.live_edition && document.live_edition.state != "removed"
      end
  end

  def self.export_to_hash(document)
    {
      content_id: document[:content_id],
      created_at: document[:created_at],
      first_published_at: document[:first_published_at],
      updated_at: document[:updated_at],
    }
  end
end
