# frozen_string_literal: true

RSpec.describe "documents/show.html.erb" do
  include TopicsHelper
  before { populate_default_government_bulk_data }

  describe "topics" do
    let(:document_type) { build(:document_type, topics: true) }
    let(:edition) { build(:edition, document_type_id: document_type.id) }
    before { assign(:edition, edition) }

    it "shows the topics when a document has topics" do
      stub_publishing_api_has_links(content_id: edition.content_id,
                                    links: { "taxons" => %w(level_three_topic) })
      stub_publishing_api_has_taxonomy

      expect(render)
        .to have_selector("#topics", text: "Level One Topic")
        .and have_selector("#topics", text: "Level Two Topic")
        .and have_selector("#topics", text: "Level Three Topic")
    end

    it "shows a message when a document doesn't have topics" do
      stub_publishing_api_has_links(content_id: edition.content_id, links: {})
      expect(render).to include(I18n.t!("documents.show.topics.no_topics"))
    end

    it "shows a message when topics can't be loaded" do
      stub_publishing_api_isnt_available
      expect(render).to include(I18n.t!("documents.show.topics.api_down"))
    end
  end

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
