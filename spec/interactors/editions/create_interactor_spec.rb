RSpec.describe Editions::CreateInteractor do
  describe ".call" do
    let(:user) { create :user }

    before do
      populate_default_government_bulk_data
      stub_any_publishing_api_put_content
    end

    it "resets the edition metadata" do
      edition = create(
        :edition,
        live: true,
        change_note: "note",
        proposed_publish_time: Time.zone.now,
        update_type: :minor,
      )

      params = { document: edition.document.to_param }

      next_edition = described_class
        .call(params: params, user: user)
        .next_edition

      expect(next_edition.update_type).to eq "major"
      expect(next_edition.change_note).to be_empty
      expect(next_edition.proposed_publish_time).to be_nil
      expect(next_edition).to be_draft
      expect(next_edition).to be_current
    end

    it "sends a preview of the new edition to the Publishing API" do
      old_edition = create(:edition, :published)

      expect(FailsafeDraftPreviewService).to receive(:call)
      expect(FailsafeDraftPreviewService).not_to receive(:call).with(old_edition)

      described_class
        .call(params: { document: old_edition.document.to_param }, user: user)
    end

    context "when the edition was discarded" do
      let(:live_edition) { create(:edition, :published) }
      let(:params) { { document: live_edition.document.to_param } }

      let!(:discarded_edition) do
        create(
          :edition,
          state: "discarded",
          current: false,
          document: live_edition.document,
        )
      end

      it "delegates to the CreateNextEditionService" do
        expect(CreateNextEditionService)
          .to receive(:call)
          .with(current_edition: live_edition,
                user: user,
                discarded_edition: discarded_edition)
          .and_call_original
        described_class.call(params: params, user: user)
      end

      it "creates a timeline entry" do
        next_edition = described_class
          .call(params: params, user: user)
          .next_edition

        entry = TimelineEntry.last
        expect(entry.entry_type).to eq "draft_reset"
        expect(entry.status).to eq next_edition.status
      end
    end

    context "when there is not a discarded edition" do
      let(:edition) { create(:edition, :published, number: 2) }
      let(:params) { { document: edition.document.to_param } }

      it "delegates to the CreateNextEditionService" do
        expect(CreateNextEditionService)
          .to receive(:call)
          .with(current_edition: edition, user: user, discarded_edition: nil)
          .and_call_original
        described_class.call(params: params, user: user)
      end

      it "creates a timeline entry" do
        next_edition = described_class
          .call(params: params, user: user)
          .next_edition

        entry = TimelineEntry.last
        expect(entry.entry_type).to eq "new_edition"
        expect(entry.status).to eq next_edition.status
      end
    end
  end
end
