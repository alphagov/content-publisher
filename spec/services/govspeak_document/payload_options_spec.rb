# frozen_string_literal: true

RSpec.describe GovspeakDocument::PayloadOptions do
  let(:organisation_service) { instance_double(OrganisationService) }

  before do
    allow(OrganisationService).to receive(:new) { organisation_service }
  end

  describe "#to_h" do
    it "returns a hash of image attributes" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: "Some alt text",
                             caption: "An optional caption",
                             credit: "An optional credit",
                             filename: "filename.png")
      edition = build(:edition, image_revisions: [image_revision])

      payload_options = GovspeakDocument::PayloadOptions.new("govspeak", edition)
      actual_image_options = payload_options.to_h[:images].first

      expect(actual_image_options).to match(
        a_hash_including(
          id: "filename.png",
          alt_text: "Some alt text",
          caption: "An optional caption",
          credit: "An optional credit",
          url: a_string_matching(%r{/media/.*/filename.png}),
        ),
      )
    end

    it "returns a hash of file attachment attributes" do
      file_attachment_revision = build(:file_attachment_revision,
                                       :on_asset_manager,
                                       fixture: "13kb-1-page-attachment.pdf",
                                       filename: "13kb-1-page-attachment.pdf",
                                       title: "A title",
                                       number_of_pages: 1)
      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      allow(organisation_service)
        .to receive(:alternative_format_contact_email) { "foo@bar.com" }

      payload_options = GovspeakDocument::PayloadOptions.new("govspeak", edition)
      actual_attachment_options = payload_options.to_h[:attachments].first

      expect(actual_attachment_options).to match(
        a_hash_including(
          id: "13kb-1-page-attachment.pdf",
          filename: "13kb-1-page-attachment.pdf",
          title: "A title",
          content_type: "application/pdf",
          number_of_pages: 1,
          file_size: 13264,
          url: a_string_matching(%r{/media/.*/13kb-1-page-attachment.pdf}),
          alternative_format_contact_email: "foo@bar.com",
        ),
      )
    end
  end
end
