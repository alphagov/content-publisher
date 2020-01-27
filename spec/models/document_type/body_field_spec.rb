# frozen_string_literal: true

RSpec.describe DocumentType::BodyField do
  describe "#payload" do
    it "returns a hash with 'body' converted to Govspeak" do
      edition = build(:edition, contents: { body: "Hey **buddy**!" })
      payload = subject.payload(edition)
      expect(payload[:details][:body]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end
end
