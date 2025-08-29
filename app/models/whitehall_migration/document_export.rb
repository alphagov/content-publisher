class WhitehallMigration::DocumentExport
  def self.exportable_documents
    @exportable_documents ||= Document
      .includes(:live_edition)
      .select do |document|
        document.live_edition && document.live_edition.state != "removed"
      end
  end
end
