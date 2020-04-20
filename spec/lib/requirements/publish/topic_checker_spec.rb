RSpec.describe Requirements::Publish::TopicChecker do
  include TopicsHelper

  describe ".call" do
    let(:document_type) { create :document_type, topics: true }
    let(:edition) { create :edition, document_type: document_type }

    it "returns no issues if there are none" do
      edition = create :edition, :publishable
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    context "when the Publishing API is available" do
      before do
        stub_publishing_api_has_links(
          "content_id" => edition.content_id,
          "links" => {},
          "version" => 3,
        )

        stub_publishing_api_has_taxonomy
      end

      it "returns an issue if there are no topics" do
        issues = described_class.call(edition)
        expect(issues).to have_issue(:topics, :none, styles: %i[form summary])
      end
    end

    context "when the Publishing API is down" do
      before do
        stub_publishing_api_isnt_available
      end

      it "raises an exception" do
        expect { described_class.call(edition) }
          .to raise_error GdsApi::BaseError
      end
    end
  end
end
