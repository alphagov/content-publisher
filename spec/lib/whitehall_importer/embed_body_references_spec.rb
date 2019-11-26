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

    it "converts Whitehall image syntax to Content Publisher syntax" do
      govspeak_body = described_class.call(
        body: "!!1 test !!2",
        images: ["foo.png", "bar.jpg"],
      )

      expect(govspeak_body).to eq("[Image:foo.png] test [Image:bar.jpg]")
    end
  end
end
