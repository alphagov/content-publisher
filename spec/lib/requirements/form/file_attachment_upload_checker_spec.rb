RSpec.describe Requirements::Form::FileAttachmentUploadChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      file = fixture_file_upload("text-file-74bytes.txt", "text/plain")
      issues = described_class.call(file:, title: "Cool title")
      expect(issues).to be_empty
    end

    it "returns no upload issues for a text file when it has no extension" do
      file = fixture_file_upload("no_extension", "text/plain")
      issues = described_class.call(file:, title: nil)
      expect(issues.items_for(:file_attachment_upload)).to be_empty
    end

    it "returns no upload issues when a zip file contains supported file types" do
      file = fixture_file_upload("valid_zip.zip", "application/zip")
      issues = described_class.call(file:, title: nil)
      expect(issues.items_for(:file_attachment_upload)).to be_empty
    end

    it "returns an issue when there is no title" do
      issues = described_class.call(file: nil, title: "")
      expect(issues).to have_issue(:file_attachment_title, :blank)
    end

    it "returns an issue when the title is too long" do
      max_length = Requirements::Form::FileAttachmentUploadChecker::TITLE_MAX_LENGTH
      title = "z" * (max_length + 1)
      issues = described_class.call(file: nil, title:)
      expect(issues).to have_issue(:file_attachment_title, :too_long, max_length:)
    end

    it "returns an issue when the file type is not supported" do
      file = fixture_file_upload("bad_file.rb", "application/x-ruby")
      issues = described_class.call(file:, title: "Cool title")
      expect(issues).to have_issue(:file_attachment_upload, :unsupported_type)
    end

    it "returns an issue when the zip file contains unsupported file types" do
      file = fixture_file_upload("unsupported_type_in_zip.zip", "application/zip")
      issues = described_class.call(file:, title: "Cool title")
      expect(issues).to have_issue(:file_attachment_upload, :zip_unsupported_type)
    end
  end
end
