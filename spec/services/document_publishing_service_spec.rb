# frozen_string_literal: true

RSpec.describe DocumentPublishingService do
  let(:document) { create :document }

  before do
    allow(document).to receive(:update!)
  end

  describe "#publish" do
    it "keeps track of the publication state" do
      stub_any_publishing_api_publish
      DocumentPublishingService.new.publish(document, "reviewed")
      expect(document).to have_received(:update!).with(publication_state: "sending_to_live", review_state: "reviewed")
      expect(document).to have_received(:update!).with(publication_state: "sent_to_live", has_live_version_on_govuk: true)
    end

    it "keeps track of the publication state on error" do
      publishing_api_isnt_available
      expect { DocumentPublishingService.new.publish(document, "reviewed") }.to raise_error GdsApi::BaseError
      expect(document).to_not have_received(:update!).with(publication_state: "sent_to_live", has_live_version_on_govuk: true)
      expect(document).to have_received(:update!).with(publication_state: "error_sending_to_live")
    end
  end
end
