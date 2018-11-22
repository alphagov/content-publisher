# frozen_string_literal: true

RSpec.describe DocumentPublishingService do
  let(:document) { create :document }

  before do
    allow(document).to receive(:update!)
  end

  describe "#publish_draft" do
    it "keeps track of the publication state" do
      stub_any_publishing_api_put_content
      DocumentPublishingService.new.publish_draft(document)
      expect(document).to have_received(:update!).with(publication_state: "sending_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "sent_to_draft")
    end

    it "keeps track of the publication state on error" do
      publishing_api_isnt_available
      expect { DocumentPublishingService.new.publish_draft(document) }.to raise_error GdsApi::BaseError
      expect(document).to_not have_received(:update!).with(publication_state: "sent_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "error_sending_to_draft")
    end
  end

  describe "#try_publish_draft" do
    it "keeps track of the publication state on error" do
      stub_any_publishing_api_put_content
      DocumentPublishingService.new.try_publish_draft(document)
      expect(document).to have_received(:update!).with(publication_state: "sending_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "sent_to_draft")
    end

    it "keeps track of the publication state on error" do
      publishing_api_isnt_available
      DocumentPublishingService.new.try_publish_draft(document)
      expect(document).to_not have_received(:update!).with(publication_state: "sent_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "error_sending_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "changes_not_sent_to_draft")
    end
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

  describe "#discard_draft" do
    it "keeps track of the publication state" do
      stub_publishing_api_discard_draft(document.content_id)
      DocumentPublishingService.new.discard_draft(document)
      expect(document).to have_received(:update!).with(publication_state: "changes_not_sent_to_draft")
    end

    it "keeps track of the publication state on error" do
      publishing_api_isnt_available
      expect { DocumentPublishingService.new.discard_draft(document) }.to raise_error GdsApi::BaseError
      expect(document).to_not have_received(:update!).with(publication_state: "changes_not_sent_to_draft")
      expect(document).to have_received(:update!).with(publication_state: "error_deleting_draft")
    end
  end
end
