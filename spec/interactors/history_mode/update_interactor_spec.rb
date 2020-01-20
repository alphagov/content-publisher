# frozen_string_literal: true

RSpec.describe HistoryMode::UpdateInteractor do
  describe ".call" do
    let(:user) { create(:user, managing_editor: true) }
    let(:edition) { create(:edition, :not_political) }
    let(:args) do
      {
        params: {
          document: edition.document.to_param,
          political: "yes",
        },
        user: user,
      }
    end

    before { stub_any_publishing_api_put_content }

    it "sets the edition to political" do
      HistoryMode::UpdateInteractor.call(**args)
      edition.reload

      expect(edition.political?).to be true
    end

    it "sets the edition to not political" do
      args[:params][:political] = "no"
      HistoryMode::UpdateInteractor.call(**args)
      edition.reload

      expect(edition.political?).to be false
    end

    it "creates a timeline entry" do
      HistoryMode::UpdateInteractor.call(**args)
      edition.reload

      expect(edition.timeline_entries.last.entry_type).to eq("political_status_changed")
    end

    it "sends a preview of the new edition to the Publishing API" do
      expect(FailsafeDraftPreviewService).to receive(:call)

      HistoryMode::UpdateInteractor.call(**args)
    end
  end
end
