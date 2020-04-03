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

    context "when the attachment has extra metadata fields" do
      let(:edition) do
        create(:edition, document_type: build(:document_type, attachments: "featured"))
      end

      it "can add isbn and unique reference attributes" do
        attachment = create(:file_attachment_revision,
                            isbn: "9788700631625", unique_reference: "unique ref")

        payload = described_class.new(attachment, edition).payload

        expect(payload).to match a_hash_including(
          isbn: attachment.isbn,
          unique_reference: attachment.unique_reference,
        )
      end

      it "can add an unnumbered hoc paper attribute" do
        attachment = create(:file_attachment_revision, official_document_type: "act_paper")
        payload = described_class.new(attachment, edition).payload
        expect(payload).to match a_hash_including(unnumbered_hoc_paper: true)
        expect(payload.keys).not_to include(:hoc_paper_number)
      end

      it "can add an unnumbered command paper attribute" do
        attachment = create(:file_attachment_revision, official_document_type: "command_paper")
        payload = described_class.new(attachment, edition).payload
        expect(payload).to match a_hash_including(unnumbered_command_paper: true)
        expect(payload.keys).not_to include(:command_paper_number)
      end

      it "can add a numbered House of Commons paper attribute" do
        attachment = create(:file_attachment_revision,
                            official_document_type: "act_paper",
                            paper_number: "123")
        payload = described_class.new(attachment, edition).payload
        expect(payload).to match a_hash_including(hoc_paper_number: "123")
        expect(payload.keys).not_to include(:unnumbered_hoc_paper)
        expect(payload.keys).not_to include(:command_paper_number)
      end

      it "can add a numbered command paper attribute" do
        attachment = create(:file_attachment_revision,
                            official_document_type: "command_paper",
                            paper_number: "CP 123")
        payload = described_class.new(attachment, edition).payload
        expect(payload).to match a_hash_including(command_paper_number: "CP 123")
        expect(payload.keys).not_to include(:unnumbered_command_paper)
        expect(payload.keys).not_to include(:hoc_paper_number)
      end
    end
  end
end
