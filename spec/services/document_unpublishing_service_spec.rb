# frozen_string_literal: true

RSpec.describe DocumentUnpublishingService do
  describe "#retire" do
    let(:document) { create(:document) }
    let(:explanatory_note) { "The document is out of date" }

    it "withdraws a document in publishing-api with an explanatory note" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })
      DocumentUnpublishingService.new.retire(document, explanatory_note)

      assert_publishing_api_unpublish(document.content_id, type: "withdrawal", explanation: explanatory_note, locale: document.locale)
    end

    it "sets the locale of the document if specified" do
      french_document = create(:document, locale: "fr")

      stub_publishing_api_unpublish(french_document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: french_document.locale })
      DocumentUnpublishingService.new.retire(french_document, explanatory_note)

      assert_publishing_api_unpublish(french_document.content_id, type: "withdrawal", explanation: explanatory_note, locale: french_document.locale)
    end

    it "does not delete assets for retired documents" do
      asset = create(:image, :in_asset_manager, document: document)
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })

      DocumentUnpublishingService.new.retire(document, explanatory_note)

      assert_not_requested asset_manager_delete_asset(asset.asset_manager_id)
    end
  end

  describe "#remove" do
    let(:document) { create(:document) }

    it "removes a document" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })
      DocumentUnpublishingService.new.remove(document)

      assert_publishing_api_unpublish(document.content_id, type: "gone")
    end

    it "deletes assets associated with removed documents" do
      asset = create(:image, :in_asset_manager, document: document)
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })
      asset_manager_request = asset_manager_delete_asset(asset.asset_manager_id)

      DocumentUnpublishingService.new.remove(document)

      assert_requested(asset_manager_request)
    end
  end
end
