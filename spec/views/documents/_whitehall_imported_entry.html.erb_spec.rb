# frozen_string_literal: true

RSpec.describe "documents/_whitehall_imported_entry.html.erb" do
  describe "Whitehall imported entry" do
    it "shows a Whitehall timeline entry without an author" do
      whitehall_imported_entry = create(:whitehall_imported_entry)
      timeline_entry = create(:timeline_entry,
                              entry_type: "whitehall_migration",
                              details_type: "TimelineEntry::WhitehallImportedEntry",
                              details_id: whitehall_imported_entry.id,
                              created_by: nil)
      render partial: "documents/whitehall_imported_entry", locals: { entry: timeline_entry }
      expect(rendered).not_to include(" by ")
      expect(rendered).to include(I18n.t("documents.history.entry_types.whitehall_migration.new_edition"))
    end

    it "shows a Whitehall timeline entry with an author" do
      whitehall_imported_entry = create(:whitehall_imported_entry)
      timeline_entry = create(:timeline_entry,
                              entry_type: "whitehall_migration",
                              details_type: "TimelineEntry::WhitehallImportedEntry",
                              details_id: whitehall_imported_entry.id)
      render partial: "documents/whitehall_imported_entry", locals: { entry: timeline_entry }
      expect(rendered).to include(" by John Smith")
      expect(rendered).to include(I18n.t("documents.history.entry_types.whitehall_migration.new_edition"))
    end
  end
end
