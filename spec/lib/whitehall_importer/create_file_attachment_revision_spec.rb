# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateFileAttachmentRevision do
  let(:whitehall_file_attachment) do
    build(:whitehall_export_file_attachment)
  end

  context "creates a file attachment" do
    it "fetches file from asset-manager" do
      create_revision = described_class.new(whitehall_file_attachment)
      expect(create_revision.call).to have_requested(:get, whitehall_file_attachment["url"])
    end

    it "creates a FileAttachment::BlobRevision" do
      expect { described_class.call(whitehall_file_attachment) }
        .to change { FileAttachment::BlobRevision.count }.by(1)
    end
  end

  context "aborts creating a file attachment" do
    it "for an invalid url" do
      stub_request(:get, whitehall_file_attachment["url"]).to_return(status: 404)
      create_revision = described_class.new(whitehall_file_attachment)

      expect { create_revision.call }.to raise_error(
        WhitehallImporter::AbortImportError,
        "File attachment does not exist: #{whitehall_file_attachment['url']}",
      )
    end

    it "for a file attachment with requirements issues" do
      too_long_title = ("A" * Requirements::FileAttachmentChecker::TITLE_MAX_LENGTH) + "A"
      whitehall_file_attachment = build(
        :whitehall_export_file_attachment,
        title: too_long_title,
      )

      expect { described_class.call(whitehall_file_attachment) }.to raise_error(
        WhitehallImporter::AbortImportError,
        I18n.t!("requirements.title.too_long.form_message", max_length: Requirements::FileAttachmentChecker::TITLE_MAX_LENGTH),
      )
    end
  end
end
