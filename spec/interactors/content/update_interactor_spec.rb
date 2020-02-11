RSpec.describe Content::UpdateInteractor do
  describe ".call" do
    before { stub_any_publishing_api_put_content }

    let(:edition) { create(:edition, number: 2) }
    let(:user) { build(:user) }

    let(:params) do
      ActionController::Parameters.new(document: edition.document.to_param,
                                       summary: "New summary",
                                       change_note: "New note",
                                       update_type: "minor")
    end

    it "succeeds with default parameters" do
      result = described_class.call(params: params, user: user)
      expect(result).to be_success
    end

    it "updates the edition" do
      expect { described_class.call(params: params, user: user) }
        .to change { edition.reload.summary }.to("New summary")
        .and change { edition.reload.change_note }.to("New note")
        .and change { edition.reload.update_type }.to("minor")
    end

    it "ignores change notes for first editions" do
      params.merge!(document: create(:edition).document.to_param)
      change_note = edition.change_note
      described_class.call(params: params, user: user)
      expect(edition.reload.change_note).to eq change_note
      expect(edition.update_type).to eq "major"
    end

    it "creates a timeline entry" do
      expect { described_class.call(params: params, user: user) }
        .to change { TimelineEntry.where(entry_type: :updated_content).count }
        .by(1)
    end

    it "updates the preview" do
      expect(FailsafeDraftPreviewService).to receive(:call).with(edition)
      described_class.call(params: params, user: user)
    end

    it "raises an error when the edition isn't editable" do
      params.merge!(document: create(:edition, :published).document.to_param)

      expect { described_class.call(params: params, user: user) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "fails if the content is unchanged" do
      params.merge!(summary: edition.summary,
                    change_note: edition.change_note,
                    update_type: edition.update_type)
      result = described_class.call(params: params, user: user)
      expect(result).to be_failure
    end

    it "fails if there are issues with the input" do
      params.merge!(summary: "new\nline")
      result = described_class.call(params: params, user: user)
      expect(result).to be_failure
      expect(result.issues).to have_issue(:summary, :multiline)
    end
  end
end
