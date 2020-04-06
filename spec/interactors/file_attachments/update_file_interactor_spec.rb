RSpec.describe FileAttachments::UpdateFileInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:attachment) { create(:file_attachment_revision) }
    let(:file) { fixture_file_upload("files/13kb-1-page-attachment.pdf") }

    let(:edition) do
      create :edition, file_attachment_revisions: [attachment]
    end

    let(:params) do
      ActionController::Parameters.new(
        file_attachment: {
          file: file,
          title: "My title",
        },
        document: edition.document.to_param,
        file_attachment_id: attachment.file_attachment_id,
      )
    end

    before do
      allow(FailsafeDraftPreviewService).to receive(:call)
    end

    it "generates a unique filename for the attachment" do
      other_attachment = create :file_attachment_revision
      edition = create :edition, file_attachment_revisions: [attachment, other_attachment]
      params.merge!(document: edition.document.to_param)

      expect(GenerateUniqueFilenameService).to receive(:call)
        .with(existing_filenames: [other_attachment.filename],
              filename: file.original_filename)
        .and_call_original

      described_class.call(params: params, user: user)
    end
  end
end
