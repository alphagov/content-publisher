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
  end
end
