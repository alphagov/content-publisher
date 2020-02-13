RSpec.describe Editions::DestroyInteractor do
  describe ".call" do
    let(:edition) { create(:edition) }
    let(:user) { create :user }

    let(:params) do
      ActionController::Parameters.new(document: edition.document.to_param)
    end

    before do
      stub_publishing_api_unreserve_path(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)
    end

    it "discards an edition" do
      result = described_class.call(params: params, user: user)
      expect(result).to be_success
      expect(result.edition).to be_discarded
    end

    it "delegates to the DiscardDraftEditionService" do
      expect(DiscardDraftEditionService)
        .to receive(:call)
        .with(edition, user)
      described_class.call(params: params, user: user)
    end

    it "creates a timeline entry" do
      expect { described_class.call(params: params, user: user) }
        .to change { TimelineEntry.where(entry_type: :draft_discarded).count }
        .by(1)
    end

    context "when the Publishing API is down" do
      before { stub_publishing_api_isnt_available }

      it "fails with an api_error flag" do
        result = described_class.call(params: params, user: user)
        expect(result).to be_failure
        expect(result.api_error).to be(true)
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { described_class.call(params: params, user: user) }
          .to raise_error(EditionAssertions::StateError)
      end
    end
  end
end
