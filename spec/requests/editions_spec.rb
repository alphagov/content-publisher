# frozen_string_literal: true

RSpec.describe "Editions" do
  describe "POST /document/:document/editions" do
    it "creates a new edition" do
      edition = create(:edition, :published)
      stub_publishing_api_put_content(edition.content_id, {})

      expect { post create_edition_path(edition.document) }
        .to change { Edition.where(document_id: edition.document.id).count }.by(1)
    end
  end
end
