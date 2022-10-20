RSpec.describe Schedule::DestroyInteractor do
  let(:scheduling) { build(:scheduling) }
  let(:edition) { create(:edition, :scheduled, scheduling:) }
  let(:user) { build(:user) }
  let(:params) { { document: edition.document.to_param } }

  describe "#call" do
    let!(:destroy_intent_request) do
      stub_publishing_api_destroy_intent(edition.base_path)
    end

    it "creates a timeline entry" do
      result = described_class.call(params:, user:)
      timeline_entry = result.edition.timeline_entries.last

      expect(timeline_entry.entry_type).to eq("unscheduled")
    end

    it "makes a request to Publishing API to destroy the existing publishing intent" do
      described_class.call(params:, user:)

      expect(destroy_intent_request).to have_been_requested
    end

    it "returns an api_error flag when Publishing API is down" do
      stub_publishing_api_isnt_available
      result = described_class.call(params:, user:)

      expect(result.api_error).to be_truthy
    end

    context "when the scheduling reviewed state is set to true" do
      it "sets the edition's status to 'submitted_for_review'" do
        scheduling = build(:scheduling, reviewed: true)
        edition = create(:edition, :scheduled, scheduling:)
        stub_publishing_api_destroy_intent(edition.base_path)

        result = described_class.call(
          params: { document: edition.document.to_param }, user:,
        )

        expect(result.edition.status).to be_submitted_for_review
      end
    end

    context "when the scheduling reviewed state is set to false" do
      it "sets the edition's status to 'draft'" do
        result = described_class.call(params:, user:)

        expect(result.edition.status).to be_draft
      end
    end
  end
end
