# frozen_string_literal: true

RSpec.describe Requirements::FileAttachmentUploadChecker do
  describe "#errors" do
    it "returns no issues if there are none" do
      file = fixture_file_upload("files/text-file.txt", "text/plain")

      issues = Requirements::FileAttachmentUploadChecker.new(file, "Cool title").issues
      expect(issues.items).to be_empty
    end

    it "returns an issue when there is no title" do
      file = fixture_file_upload("files/text-file.txt", "text/plain")
      issues = Requirements::FileAttachmentUploadChecker.new(file, "").issues

      form_message = issues.items_for(:file_attachment_title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.file_attachment_title.blank.form_message"))
    end

    it "returns an issue when the title is too long" do
      max_length = Requirements::FileAttachmentUploadChecker::TITLE_MAX_LENGTH
      file = fixture_file_upload("files/text-file.txt", "text/plain")
      title = "z" * (max_length + 1)
      issues = Requirements::FileAttachmentUploadChecker.new(file, title).issues

      form_message = issues.items_for(:file_attachment_title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.file_attachment_title.too_long.form_message", max_length: max_length))
    end

    it "returns an issue when no file_attachment is specified" do
      issues = Requirements::FileAttachmentUploadChecker.new(nil, "Cool title").issues

      form_message = issues.items_for(:file_attachment_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.file_attachment_upload.no_file.form_message"))
    end
  end
end
