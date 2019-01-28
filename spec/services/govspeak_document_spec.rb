# frozen_string_literal: true

RSpec.describe GovspeakDocument do
  describe "#in_app_html" do
    it "converts the provided text to HTML" do
      expect(GovspeakDocument.new("## Hullo").in_app_html)
        .to match(%{<h2 id="hullo">Hullo</h2>})
    end

    context "when an unknown contact is referenced" do
      it "renders an empty string" do
        content_id = SecureRandom.uuid
        govspeak = "[Contact:#{content_id}]"
        stub_publishing_api_get_editions([], ContactsService::EDITION_PARAMS)
        expect(GovspeakDocument.new(govspeak).in_app_html).to eql("\n")
      end
    end

    context "when a known contact that is referenced" do
      it "renders the contact" do
        content_id = SecureRandom.uuid
        stub_publishing_api_get_editions(
          [
            {
              "content_id" => content_id,
              "title" => "Clark Kent",
              "description" => "Prone to lengthy work absences",
              "details" => {
                "email_addresses" => [
                  "email" => "clark@dailyplanet.com",
                  "title" => "Mail Clark",
                ],
              },
            },
          ],
          ContactsService::EDITION_PARAMS,
        )

        govspeak = "[Contact:#{content_id}]"
        expect(GovspeakDocument.new(govspeak).in_app_html)
          .to match(%{<a href="mailto:clark@dailyplanet.com" class="email">Mail Clark</a>})
      end
    end
  end

  describe "#payload_html" do
    it "converts the provided text to HTML" do
      expect(GovspeakDocument.new("## Hullo").payload_html)
        .to match(%{<h2 id="hullo">Hullo</h2>})
    end

    context "when an unknown contact is referenced" do
      it "renders an empty string" do
        content_id = SecureRandom.uuid
        govspeak = "[Contact:#{content_id}]"
        stub_publishing_api_get_editions([], ContactsService::EDITION_PARAMS)
        expect(GovspeakDocument.new(govspeak).payload_html).to eql("\n")
      end
    end

    context "when a known contact that is referenced" do
      it "renders the contact" do
        content_id = SecureRandom.uuid
        stub_publishing_api_get_editions(
          [
            {
              "content_id" => content_id,
              "title" => "Clark Kent",
              "description" => "Prone to lengthy work absences",
              "details" => {
                "email_addresses" => [
                  "email" => "clark@dailyplanet.com",
                  "title" => "Mail Clark",
                ],
              },
            },
          ],
          ContactsService::EDITION_PARAMS,
        )

        govspeak = "[Contact:#{content_id}]"
        expect(GovspeakDocument.new(govspeak).payload_html)
          .to match(%{<a href="mailto:clark@dailyplanet.com" class="email">Mail Clark</a>})
      end
    end
  end

end
