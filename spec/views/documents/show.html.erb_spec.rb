# frozen_string_literal: true

RSpec.describe "documents/show.html.erb" do
  before { populate_default_government_bulk_data }

  describe "history mode banner" do
    it "shows a history mode banner for political content associated with past government" do
      edition = build(:edition, :political, government: past_government)
      assign(:edition, edition)
      render

      title = I18n.t!("documents.show.historical.title",
                      document_type: edition.document_type.label.downcase)
      description = I18n.t!("documents.show.historical.description",
                            government_name: edition.government.title)
      expect(rendered)
        .to include(title)
        .and include(description)
    end

    it "doesn't show a history mode banner for political content associated with current government" do
      edition = build(:edition, :political, government: current_government)
      assign(:edition, edition)
      render

      title = I18n.t!("documents.show.historical.title",
                      document_type: edition.document_type.label.downcase)
      expect(rendered).not_to include(title)
    end

    it "doesn't show a history mode banner for non-political content" do
      edition = build(:edition, :not_political)
      assign(:edition, edition)
      render

      title = I18n.t!("documents.show.historical.title",
                      document_type: edition.document_type.label.downcase)
      expect(rendered).not_to include(title)
    end
  end
end
