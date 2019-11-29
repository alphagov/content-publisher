# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
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
