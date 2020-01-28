# frozen_string_literal: true

RSpec.describe Content::UpdateInteractor do
  describe ".call" do
    before { stub_any_publishing_api_put_content }
    let(:edition) { create(:edition) }
    let(:user) { build(:user) }

    def build_params(document: edition.document,
                     title: SecureRandom.alphanumeric(10),
                     summary: SecureRandom.alphanumeric(10))
      ActionController::Parameters.new(
        document: document.to_param,
        revision: { title: title, summary: summary },
      )
    end

    it "succeeds with default parameters" do
      result = Content::UpdateInteractor.call(params: build_params, user: user)
      expect(result).to be_success
    end

    it "updates the edition" do
      params = build_params(title: "New title", summary: "New summary")

      expect { Content::UpdateInteractor.call(params: params, user: user) }
        .to change { edition.reload.title }.to("New title")
        .and change { edition.reload.summary }.to("New summary")
    end

    it "creates a timeline entry" do
      expect { Content::UpdateInteractor.call(params: build_params, user: user) }
        .to change { TimelineEntry.where(entry_type: :updated_content).count }
        .by(1)
    end

    it "updates the preview" do
      expect(FailsafeDraftPreviewService).to receive(:call).with(edition)
      Content::UpdateInteractor.call(params: build_params, user: user)
    end

    it "raises an error when the edition isn't editable" do
      params = build_params(document: create(:edition, :published).document)

      expect { Content::UpdateInteractor.call(params: params, user: user) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "fails if the content is unchanged" do
      params = build_params(title: edition.title, summary: edition.summary)
      result = Content::UpdateInteractor.call(params: params, user: user)
      expect(result).to be_failure
    end

    it "fails if there are issues with the input" do
      params = build_params(title: "")
      result = Content::UpdateInteractor.call(params: params, user: user)
      expect(result).to be_failure
      expect(result.issues).to have_issue(:title, :blank)
    end
  end
end
