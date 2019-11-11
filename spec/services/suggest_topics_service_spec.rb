# frozen_string_literal: true

RSpec.describe SuggestTopicsService do
  include TopicsHelper

  describe ".call" do
    let(:edition) { create(:edition) }

    before do
      stub_publishing_api_has_taxonomy
    end

    context "the API responds with suggestions" do
      let(:edition) { create(:edition) }
      before do
        stub_request(:post, Rails.application.secrets.tagging_suggester_api_url).
          with(
            body: {
              "text" => "#{edition.title} #{edition.summary} #{edition.contents.values.join(" ")}"
            }
          ).
          to_return(
            body:
              {
                suggestions: [
                  { taxon: 'taxon-content-id', explanation: %w(word_one word_two) },
                  { taxon: 'another-taxon-content-id', explanation: %w(word_three word_four) },
                ]
              }.to_json
          )
      end

      it "parses the results correctly" do
        expect(SuggestTopicsService.call(edition).count).to eq(2)
      end
    end

    context "the API throws an error" do
      before do
        stub_request(:post, Rails.application.secrets.tagging_suggester_api_url).to_raise(Timeout::Error)
      end

      it "returns an empty array" do
        expect(SuggestTopicsService.call(edition).count).to eq(0)
      end
    end
  end
end
