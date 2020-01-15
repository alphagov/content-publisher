# frozen_string_literal: true

RSpec.describe "documents/_timeline_entry.html.erb" do
  describe "timeline entry" do
    it "shows a timeline entry without an author" do
      timeline_entry = create(:timeline_entry,
                              created_by: nil)
      render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
      expect(rendered).not_to include(" by ")
      expect(rendered).to include(I18n.t("documents.history.entry_types.created"))
    end

    it "shows a Whitehall timeline entry with an author" do
      timeline_entry = create(:timeline_entry)
      render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
      expect(rendered).to include(" by John Smith")
      expect(rendered).to include(I18n.t("documents.history.entry_types.created"))
    end
  end
end
