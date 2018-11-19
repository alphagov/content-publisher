# frozen_string_literal: true

RSpec.describe DocumentUnpublishingService do
  describe "#retire" do
    it "withdraws a document in publishing-api with an explanatory note" do
      document = create(:document)
      explanatory_note = "The document is out of date"

      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note })
      DocumentUnpublishingService.new.retire(document, explanatory_note)

      assert_publishing_api_unpublish(document.content_id, type: "withdrawal", explanation: explanatory_note)
    end
  end

  describe "#remove" do
    let(:document) { create(:document) }

    it "removes a document" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })
      DocumentUnpublishingService.new.remove(document)

      assert_publishing_api_unpublish(document.content_id, type: "gone")
    end

    it "allows removed documents to be redirected" do
      redirect_path = "/redirect-path"

      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path })
      DocumentUnpublishingService.new.remove(document, redirect_path: redirect_path)

      assert_publishing_api_unpublish(document.content_id, type: "redirect", alternative_path: redirect_path)
    end
  end
end
