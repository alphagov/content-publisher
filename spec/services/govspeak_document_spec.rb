# frozen_string_literal: true

RSpec.describe GovspeakDocument do
  include ActiveSupport::Testing::TimeHelpers

  describe "#in_app_html" do
    it "converts the provided text to HTML" do
      edition = create(:edition)

      expect(GovspeakDocument.new("## Hullo", edition).in_app_html)
        .to match(%{<h2 id="hullo">Hullo</h2>})
    end

    context "when an unknown contact is referenced" do
      it "renders an empty string" do
        content_id = SecureRandom.uuid
        govspeak = "[Contact:#{content_id}]"
        edition = create(:edition)
        stub_publishing_api_get_editions([], ContactsService::EDITION_PARAMS)

        expect(GovspeakDocument.new(govspeak, edition).in_app_html).to eql("\n")
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
        edition = create(:edition)

        expect(GovspeakDocument.new(govspeak, edition).in_app_html)
          .to match(%{<a href="mailto:clark@dailyplanet.com" class="email">Mail Clark</a>})
      end
    end

    context "when an image is present in the markdown" do
      it "renders the uncropped image" do
        image_revision = build(:image_revision,
                               :on_asset_manager,
                               alt_text: 'Some alt text',
                               caption: 'An optional caption',
                               credit: 'An optional credit',
                               filename: 'filename.png')
        document_type = build(:document_type, lead_image: true)
        edition = build(:edition,
                        image_revisions: [image_revision],
                        document_type_id: document_type.id)

        html_output = GovspeakDocument.new("[Image: filename.png]", edition).in_app_html
        expect(html_output).to match("Some alt text")
        expect(html_output).to match("An optional caption")
        expect(html_output).to match("An optional credit")
        expect(html_output).to match("filename.png")
      end
    end
  end

  describe "#payload_html" do
    it "converts the provided text to HTML" do
      edition = create(:edition)

      expect(GovspeakDocument.new("## Hullo", edition).payload_html)
        .to match(%{<h2 id="hullo">Hullo</h2>})
    end

    context "when an unknown contact is referenced" do
      it "renders an empty string" do
        content_id = SecureRandom.uuid
        govspeak = "[Contact:#{content_id}]"
        edition = create(:edition)
        stub_publishing_api_get_editions([], ContactsService::EDITION_PARAMS)

        expect(GovspeakDocument.new(govspeak, edition).payload_html).to eql("\n")
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
        edition = create(:edition)

        expect(GovspeakDocument.new(govspeak, edition).in_app_html)
          .to match(%{<a href="mailto:clark@dailyplanet.com" class="email">Mail Clark</a>})
      end
    end

    context "when an image is present in the markdown" do
      it "renders the uncropped image" do
        image_revision = build(:image_revision,
                               :on_asset_manager,
                               alt_text: 'Some alt text',
                               caption: 'An optional caption',
                               credit: 'An optional credit',
                               filename: 'filename.png')

        document_type = build(:document_type, lead_image: true)
        edition = build(:edition,
                        image_revisions: [image_revision],
                        document_type_id: document_type.id)

        html_output = GovspeakDocument.new("[Image: filename.png]", edition).payload_html
        expect(html_output).to match("Some alt text")
        expect(html_output).to match("An optional caption")
        expect(html_output).to match("An optional credit")
        expect(html_output).to match("filename.png")
      end
    end
  end
end
