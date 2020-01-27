# frozen_string_literal: true

RSpec.describe DocumentType::SummaryField do
  describe "#payload" do
    it "returns a hash with a 'description' / summary" do
      edition = build(:edition, summary: "document summary")
      payload = subject.payload(edition)
      expect(payload).to eq(description: "document summary")
    end
  end
end
