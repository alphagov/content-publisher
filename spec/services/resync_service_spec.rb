# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
      PoliticalEditionIdentifier.stub_chain(:new, :political?).and_return(true)
    end

    context "when there is no live edition" do
      let(:document) { create(:document, :with_current_edition) }

      it "synchronises the current edition, but does not publish" do
        expect(PreviewService).to receive(:call).with(document.current_edition).and_call_original
        expect(GdsApi.publishing_api_v2).not_to receive(:publish)
        ResyncService.call(document)
        expect(document.current_edition.revision_synced).to be true
      end
    end

    context "when the current edition is live" do
      let(:document) { create(:document, :with_live_edition) }

      it "avoids synchronising the edition twice" do
        expect(PreviewService).to receive(:call).once
        ResyncService.call(document)
      end

      it "re-publishes the live edition" do
        GdsApi.stub_chain(:publishing_api_v2, :put_content)
        GdsApi.stub_chain(:publishing_api_v2, :publish)
        expect(GdsApi.publishing_api_v2).to receive(:put_content).once.
          with(document.content_id, hash_including(update_type: "republish")).ordered
        expect(GdsApi.publishing_api_v2).to receive(:publish).once.
          with(document.content_id, nil, hash_including(:locale)).ordered
        ResyncService.call(document)
        expect(document.current_edition.revision_synced).to be true
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetService).to receive(:call).once.
          with(document.live_edition, nil)
        ResyncService.call(document)
      end
    end

    context "when the current edition is withdrawn" do
      let(:document) { create(:document, :with_live_edition) }

      before do
        document.current_edition.stub(:withdrawn?).and_return(true)
        GdsApi.stub_chain(:publishing_api_v2, :put_content)
        GdsApi.stub_chain(:publishing_api_v2, :unpublish)
      end

      it "unpublishes the edition as withdrawn" do
        unpublish_params = hash_including(
          type: "withdrawal",
          locale: document.current_edition.locale,
        )
        expect(GdsApi.publishing_api_v2).to receive(:put_content).once.ordered
        expect(GdsApi.publishing_api_v2).to receive(:unpublish).once.
          with(document.content_id, unpublish_params).ordered
        ResyncService.call(document)
      end
    end

    context "when the current edition is unpublished with redirect" do
      let(:document) { create(:document, :with_live_edition) }

      before do
        document.current_edition.stub(:removed?).and_return(true)
        document.current_edition.status.details.stub(:redirect?).and_return(true)
        document.current_edition.status.details.stub(:alternative_path).and_return("/foo/bar")
        document.current_edition.status.details.stub(:explanatory_note).and_return("Explanation")
        GdsApi.stub_chain(:publishing_api_v2, :put_content)
        GdsApi.stub_chain(:publishing_api_v2, :unpublish)
      end

      it "unpublishes the edition as redirected" do
        unpublish_params = hash_including(
          type: "redirect",
          locale: document.current_edition.locale,
          alternative_path: "/foo/bar",
          explanation: "Explanation",
        )
        expect(GdsApi.publishing_api_v2).to receive(:put_content).once.ordered
        expect(GdsApi.publishing_api_v2).to receive(:unpublish).once.
          with(document.content_id, unpublish_params).ordered
        ResyncService.call(document)
      end
    end

    context "when there are both live and current editions" do
      let(:document) { create(:document, :with_current_and_live_editions) }

      it "updates the system_political value associated with both editions" do
        expect(document.live_edition.system_political).to be false
        expect(document.current_edition.system_political).to be false
        ResyncService.call(document)
        expect(document.live_edition.system_political).to be true
        expect(document.current_edition.system_political).to be true
      end

      it "updates the government_id associated with the live edition" do
        expect(document.live_edition.government_id).to be nil
        ResyncService.call(document)
        expect(document.live_edition.government_id).to eq "d4fbc1b9-d47d-4386-af04-ac909f868f92"
      end

      it "does not set the government_id associated with the current edition" do
        expect(document.current_edition.government_id).to be nil
        ResyncService.call(document)
        expect(document.current_edition.government_id).to be nil
      end
    end
  end
end
