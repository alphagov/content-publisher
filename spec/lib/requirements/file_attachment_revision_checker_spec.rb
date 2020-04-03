RSpec.describe Requirements::FileAttachmentRevisionChecker do
  describe "#pre_update_issues" do
    let(:max_length) { Requirements::FileAttachmentRevisionChecker::UNIQUE_REF_MAX_LENGTH }
    let(:checker) { described_class.new(build(:file_attachment_revision)) }
    let(:valid_params) { { official_document_type: "unofficial" } }

    it "returns no issues if there are none" do
      unique_reference = "z" * max_length
      issues = checker.pre_update_issues(unique_reference: unique_reference)
      expect(issues).to be_empty
    end

    it "returns an issue when the unique_reference is too long" do
      unique_reference = "z" * (max_length + 1)
      issues = checker.pre_update_issues(unique_reference: unique_reference)

      expect(issues).to have_issue(:file_attachment_unique_reference,
                                   :too_long,
                                   max_length: max_length)
    end

    [
      "invalid",
      "9788--0631625",
      "9991a9010599938",
      "0-9722051-1-F",
      "ISBN 9788700631625",
    ].each do |invalid_isbn|
      it "returns an issue for invalid isbn #{invalid_isbn}" do
        issues = checker.pre_update_issues(isbn: invalid_isbn)
        expect(issues).to have_issue(:file_attachment_isbn, :invalid)
      end
    end

    it "returns no issues when isbn is omitted" do
      issues = checker.pre_update_issues(isbn: nil)
      expect(issues).to be_empty
    end

    [
      "9788700631625",
      "1590599934",
      "159-059 9934",
      "978-159059 9938",
      "978-1-60746-006-0",
      "0-9722051-1-X",
      "0-9722051-1-x",
    ].each do |valid_isbn|
      it "returns no issues for valid isbn #{valid_isbn}" do
        issues = checker.pre_update_issues(isbn: valid_isbn)
        expect(issues).to be_empty
      end
    end
  end
end
