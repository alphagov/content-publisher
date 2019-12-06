# frozen_string_literal: true

RSpec.describe FileAttachments::CreateInteractor do
  describe ".call" do
    before { allow(FailsafePreviewService).to receive(:call) }
    let(:user) { create(:user) }
    let(:edition) { create(:edition) }
    let(:file) { fixture_file_upload("files/13kb-1-page-attachment.pdf") }
    let(:title) { "My Title" }
    let(:args) do
      {
        params: {
          document: edition.document.to_param,
          file: file,
          title: title,
        },
        user: user,
      }
    end

    context "when input is valid" do
      it "is successful" do
        expect(FileAttachments::CreateInteractor.call(**args)).to be_success
      end

      it "creates a new file attachment revision" do
        expect { FileAttachments::CreateInteractor.call(**args) }
          .to change { FileAttachment::Revision.count }.by(1)
      end

      it "delegates saving the file to the FileAttachmentBlobService" do
        expect(FileAttachmentBlobService).to receive(:call)
          .with(file: file, filename: file.original_filename, user: user)
          .and_call_original
        FileAttachments::CreateInteractor.call(**args)
      end

      it "delegates generating a unique filename to UniqueFilenameService" do
        expect(UniqueFilenameService).to receive(:call)
          .with(edition.revision.file_attachment_revisions.map(&:filename), file.original_filename)
          .and_call_original
        FileAttachments::CreateInteractor.call(**args)
      end

      it "sets the title of the File attachment" do
        result = FileAttachments::CreateInteractor.call(**args)
        file_attachment_revision = result.edition.file_attachment_revisions.first
        expect(file_attachment_revision.title).to eq(title)
      end

      it "attributes the various created file attachment models to the user" do
        result = FileAttachments::CreateInteractor.call(**args)
        file_attachment_revision = result.edition.file_attachment_revisions.first

        expect(file_attachment_revision.created_by).to eq(user)
        expect(file_attachment_revision.file_attachment.created_by).to eq(user)
        expect(file_attachment_revision.blob_revision.created_by).to eq(user)
        expect(file_attachment_revision.metadata_revision.created_by).to eq(user)
      end

      it "creates a timeline entry" do
        expect { FileAttachments::CreateInteractor.call(**args) }
          .to change { TimelineEntry.count }.by(1)
      end

      it "updates the preview" do
        expect(FailsafePreviewService).to receive(:call).with(edition)
        FileAttachments::CreateInteractor.call(**args)
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { FileAttachments::CreateInteractor.call(**args) }
          .to raise_error(EditionAssertions::StateError)
      end
    end

    context "when the uploaded file has issues" do
      it "fails with issues returned" do
        issue = Requirements::Issue.new("file", "example")
        allow(Requirements::FileAttachmentChecker)
          .to receive(:new).and_return(double(pre_upload_issues: [issue]))

        result = FileAttachments::CreateInteractor.call(**args)

        expect(result).to be_failure
        expect(result.issues).to match([issue])
      end
    end
  end
end
