# frozen_string_literal: true

RSpec.describe DocumentUnpublishingService do
  describe "#retire" do
    let(:explanatory_note) { "The document is out of date" }

    it "withdraws a document in publishing-api with an explanatory note" do
      document = create(:document)

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
  end
end
