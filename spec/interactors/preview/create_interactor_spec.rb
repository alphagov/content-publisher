RSpec.describe Preview::CreateInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:edition) { create(:edition) }
    let(:args) do
      {
        params: { document: edition.document.to_param },
        user:,
      }
    end

    context "when input is valid" do
      it "creates a preview" do
        expect(PreviewDraftEditionService).to receive(:call).with(edition)
        described_class.call(**args)
      end
    end

    context "when the edition is live" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { described_class.call(**args) }
          .to raise_error(EditionAssertions::StateError, /not live/)
      end
    end

    context "when the edition has issues" do
      it "fails with issues returned" do
        allow(Requirements::Preview::EditionChecker)
          .to receive(:call).and_return(%w[issue])

        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.issues).to eq %w[issue]
      end
    end

    context "when the preview fails" do
      it "fails with a preview_failed flag" do
        allow(PreviewDraftEditionService).to receive(:call)
                                         .and_raise(GdsApi::BaseError)
        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.preview_failed).to be(true)
      end
    end
  end
end
