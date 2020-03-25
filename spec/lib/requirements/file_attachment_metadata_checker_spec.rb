RSpec.describe Requirements::FileAttachmentMetadataChecker do
  describe "#pre_update_issues" do
    let(:max_length) { Requirements::FileAttachmentMetadataChecker::UNIQUE_REF_MAX_LENGTH }

    it "returns no issues if there are none" do
      unique_reference = "z" * max_length
      issues = described_class.new(unique_reference: unique_reference).pre_update_issues
      expect(issues).to be_empty
    end

    it "returns unique_reference issues when the unique_reference is too long" do
      unique_reference = "z" * (max_length + 1)
      issues = described_class.new(unique_reference: unique_reference).pre_update_issues

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
      it "returns isbn issues when invalid isbn #{invalid_isbn.inspect} is provided" do
        issues = described_class.new(isbn: invalid_isbn).pre_update_issues
        expect(issues).to have_issue(:file_attachment_isbn, :invalid)
      end
    end

    it "returns no issues when isbn is omitted" do
      issues = described_class.new(isbn: nil).pre_update_issues
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
      it "returns no issues when valid isbn #{valid_isbn.inspect} is provided" do
        issues = described_class.new(isbn: valid_isbn).pre_update_issues
        expect(issues).to be_empty
      end
    end
  end
end
