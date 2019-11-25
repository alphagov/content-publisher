# frozen_string_literal: true

RSpec.describe PublishService do
  describe ".call" do
    let(:user) { create(:user) }

    before do
      stub_any_publishing_api_publish
      allow(PublishAssetService).to receive(:call)
      allow(PoliticalAssociationService).to receive(:call)
    end

    context "when there is no live edition" do
      let(:edition) { create(:edition, :publishable) }

      it "publishes the current_edition" do
        publish_request = stub_publishing_api_publish(edition.content_id,
                                                      update_type: nil,
                                                      locale: edition.locale)

        PublishService.call(edition, user, with_review: true)
        expect(publish_request).to have_been_requested
        expect(edition.document.live_edition).to eq(edition)
        expect(edition).to be_published
        expect(edition).to be_live
      end

      it "can specify if edition is reviewed" do
        PublishService.call(edition, user, with_review: false)
        expect(edition).to be_published_but_needs_2i
      end
    end

    context "when there is a live edition" do
      it "supersedes the live edition" do
        document = create(:document, :with_current_and_live_editions)
        current_edition = document.current_edition
        live_edition = document.live_edition

        PublishService.call(current_edition, user, with_review: true)
        expect(document.live_edition).to eq(current_edition)
        expect(live_edition).to be_superseded
      end
    end

    it "calls the PublishAssetService" do
      document = create(:document, :with_current_and_live_editions)
      current_edition = document.current_edition
      expect(PublishAssetService).to receive(:call)
      PublishService.call(current_edition, user, with_review: true)
    end

    it "calls the PoliticalAssociationService" do
      edition = create(:edition)
      expect(PoliticalAssociationService)
        .to receive(:call)
        .with(edition, fallback_government: Government.current)
      PublishService.call(edition, user, with_review: true)
    end

    context "when the PoliticalAssociationService marks the edition as needing to sync the revision" do
      before do
        allow(PoliticalAssociationService).to receive(:call) do |edition|
          edition.update!(revision_synced: false)
        end
      end

      it "updates the preview of the content" do
        edition = create(:edition)
        expect(PreviewService).to receive(:call)
        PublishService.call(edition, user, with_review: true)
      end
    end

    context "when the edition is access limited" do
      it "removes the access limit" do
        edition = create(:edition, :access_limited)
        PublishService.call(edition, user, with_review: true)
        expect(edition.access_limit).to be_nil
      end
    end
  end
end
