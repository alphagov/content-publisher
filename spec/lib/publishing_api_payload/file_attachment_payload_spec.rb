RSpec.describe PublishingApiPayload::FileAttachmentPayload do
  describe "#payload" do
    it "generates a file attachment payload for the publishing_api" do
      attachment = build(:file_attachment_revision, number_of_pages: 1)
      edition = create(:edition, file_attachment_revisions: [attachment])

      payload = described_class.new(attachment, edition).payload

      expected_payload = {
        attachment_type: "file",
        content_type: attachment.content_type,
        file_size: attachment.byte_size,
        filename: attachment.filename,
        id: attachment.filename,
        locale: edition.locale,
        number_of_pages: attachment.number_of_pages,
        title: attachment.title,
        url: attachment.asset_url,
      }

      expect(payload).to match a_hash_including(expected_payload)
    end

    it "adds extra metadata if the document has featured attachments" do
      attachment = build(:file_attachment_revision,
                         isbn: "9788700631625", unique_reference: "unique ref")

      edition = create(:edition,
                       document_type: build(:document_type, attachments: "featured"),
                       file_attachment_revisions: [attachment])

      payload = described_class.new(attachment, edition).payload

      expected_payload = {
        isbn: attachment.isbn,
        unique_reference: attachment.unique_reference,
      }

      expect(payload).to match a_hash_including(expected_payload)
    end
  end
end
