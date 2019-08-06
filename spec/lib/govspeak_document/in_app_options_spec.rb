# frozen_string_literal: true

RSpec.describe GovspeakDocument::InAppOptions do
  include Rails.application.routes.url_helpers

  let(:organisation_service) { instance_double(Organisations) }

  before do
    allow(Organisations).to receive(:new) { organisation_service }
  end

  describe "#to_h" do
    it "returns a hash of image attributes" do
      image_revision = build(:image_revision,
                             alt_text: "Some alt text",
                             caption: "An optional caption",
                             credit: "An optional credit",
                             filename: "filename.png")
      edition = build(:edition, image_revisions: [image_revision])

      in_app_options = GovspeakDocument::InAppOptions.new("govspeak", edition)
      actual_image_options = in_app_options.to_h[:images].first

      expect(actual_image_options).to match(
        a_hash_including(
          id: "filename.png",
          alt_text: "Some alt text",
          caption: "An optional caption",
          credit: "An optional credit",
          url: a_string_matching(%r{/representations/.*/filename.png}),
        ),
      )
    end

    it "returns a hash of file attachment attributes" do
      attachment_revision = create(:file_attachment_revision,
                                   fixture: "13kb-1-page-attachment.pdf",
                                   filename: "13kb-1-page-attachment.pdf",
                                   title: "A title",
                                   number_of_pages: 1)
      edition = build(:edition,
                      file_attachment_revisions: [attachment_revision])

      allow(organisation_service)
        .to receive(:alternative_format_contact_email) { "foo@bar.com" }

      in_app_options = GovspeakDocument::InAppOptions.new("govspeak", edition)
      actual_attachment_options = in_app_options.to_h[:attachments].first

      expect(actual_attachment_options).to match(
        a_hash_including(
          id: "13kb-1-page-attachment.pdf",
          filename: "13kb-1-page-attachment.pdf",
          title: "A title",
          content_type: "application/pdf",
          number_of_pages: 1,
          file_size: 13264,
          url: preview_file_attachment_path(edition.document, attachment_revision.file_attachment),
          alternative_format_contact_email: "foo@bar.com",
        ),
      )
    end
  end
end
