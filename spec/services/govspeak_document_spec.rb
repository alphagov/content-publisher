# frozen_string_literal: true

RSpec.describe GovspeakDocument do
  describe "#to_html" do
    it "converts the provided text to HTML" do
      expect(GovspeakDocument.new("## Hullo").to_html)
        .to match(%{<h2 id="hullo">Hullo</h2>})
    end

    context "when an unknown contact is referenced" do
      it "renders an empty string" do
        content_id = SecureRandom.uuid
        govspeak = "[Contact:#{content_id}]"
        publishing_api_does_not_have_item(content_id)
        expect(GovspeakDocument.new(govspeak).to_html).to eql("\n")
      end
    end

    context "when a known contact that is referenced" do
      it "renders the contact" do
        content_id = SecureRandom.uuid

        publishing_api_has_item(
          content_id: content_id,
          locale: "en",
          title: "Clark Kent",
          description: "Prone to lengthy work absences",
          details: {
            email_addresses: [
              email: "clark@dailyplanet.com",
              title: "Mail Clark",
            ],
          },
          schema_name: "contact",
          document_type: "contact",
        )

        govspeak = "[Contact:#{content_id}]"
        expect(GovspeakDocument.new(govspeak).to_html)
          .to match(%{<a href="mailto:clark@dailyplanet.com" class="email">Mail Clark</a>})
      end
    end
  end
end
