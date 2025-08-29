RSpec.describe WhitehallMigration::DocumentExport do
  describe ".exportable_documents" do
    it "returns documents that are published (with or without 2i), or withdrawn" do
      Document.find_each(&:destroy) # Clean slate

      withdrawn_edition = create(:edition, :withdrawn)
      live_but_needs_2i = create(:edition, :published_but_needs_2i)
      documents_to_be_processed = [
        create(:document, :with_live_edition),
        create(:document, :with_current_and_live_editions),
        live_but_needs_2i.document,
        withdrawn_edition.document,
      ]

      # documents to be ignored
      create(:document, :with_current_edition)
      create(:edition, state: "submitted_for_review")
      create(:edition, :removed, removal: create(:removal, redirect: true, alternative_url: "/somewhere"))

      expect(described_class.exportable_documents.sort_by(&:id)).to eq(documents_to_be_processed.sort_by(&:id))
    end
  end
end
