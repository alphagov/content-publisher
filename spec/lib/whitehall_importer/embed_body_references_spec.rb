# frozen_string_literal: true

RSpec.describe WhitehallImporter::EmbedBodyReferences do
  describe ".call" do
    it "changes the ids of embedded contacts" do
      content_id = SecureRandom.uuid
      govspeak_body = described_class.call(
        body: "[Contact:123]",
        contacts: [{ "id" => 123, "content_id" => content_id }],
      )

      expect(govspeak_body).to eq("[Contact:#{content_id}]")
    end
  end
end
