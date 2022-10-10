RSpec.describe FileAttachments::CreateInteractor do
  describe ".call" do
    before { allow(FailsafeDraftPreviewService).to receive(:call) }

    let(:user) { create(:user) }
    let(:edition) { create(:edition) }
    let(:file) { fixture_file_upload("13kb-1-page-attachment.pdf") }
    let(:title) { "My Title" }
    let(:args) do
      {
        params: {
          document: edition.document.to_param,
          file:,
          title:,
        },
        user:,
      }
    end

    context "when input is valid" do
      it "creates a new file attachment revision" do
        expect { described_class.call(**args) }
          .to change(FileAttachment::Revision, :count).by(1)
      end

      it "delegates saving the file to the CreateFileAttachmentBlobService" do
        expect(CreateFileAttachmentBlobService).to receive(:call)
          .with(file:, filename: file.original_filename, user:)
          .and_call_original
        described_class.call(**args)
      end

      it "generates a unique filename for the attachment" do
        other_attachment = create :file_attachment_revision
        edition = create :edition, file_attachment_revisions: [other_attachment]
        args[:params].merge!(document: edition.document.to_param)

        expect(GenerateUniqueFilenameService).to receive(:call)
          .with(existing_filenames: [other_attachment.filename],
                filename: file.original_filename)
          .and_call_original

        described_class.call(**args)
      end

      it "sets the title of the File attachment" do
        result = described_class.call(**args)
        file_attachment_revision = result.edition.file_attachment_revisions.first
        expect(file_attachment_revision.title).to eq(title)
      end

      it "attributes the various created file attachment models to the user" do
        result = described_class.call(**args)
        file_attachment_revision = result.edition.file_attachment_revisions.first

        expect(file_attachment_revision.created_by).to eq(user)
        expect(file_attachment_revision.file_attachment.created_by).to eq(user)
        expect(file_attachment_revision.blob_revision.created_by).to eq(user)
        expect(file_attachment_revision.metadata_revision.created_by).to eq(user)
      end

      it "creates a timeline entry" do
        expect { described_class.call(**args) }
          .to change(TimelineEntry, :count).by(1)
      end

      it "updates the preview" do
        expect(FailsafeDraftPreviewService).to receive(:call).with(edition)
        described_class.call(**args)
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { described_class.call(**args) }
          .to raise_error(EditionAssertions::StateError)
      end
    end

    context "when the file is blank" do
      it "fails with issues returned" do
        args[:params][:file] = nil
        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.issues).to have_issue(:file_attachment_upload, :no_file)
      end
    end

    context "when the uploaded file has issues" do
      it "fails with issues returned" do
        allow(Requirements::Form::FileAttachmentUploadChecker)
          .to receive(:call).and_return(%w[issue])

        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.issues).to eq %w[issue]
      end
    end
  end
end
