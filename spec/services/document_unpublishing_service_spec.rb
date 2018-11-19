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
    it "removes a document" do
      document = create(:document)

      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })
      DocumentUnpublishingService.new.remove(document)

      assert_publishing_api_unpublish(document.content_id, type: "gone")
    end
  end
end
