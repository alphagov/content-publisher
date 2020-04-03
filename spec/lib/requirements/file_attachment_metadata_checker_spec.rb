RSpec.describe Requirements::FileAttachmentMetadataChecker do
  describe "#pre_update_issues" do
    let(:max_length) { Requirements::FileAttachmentMetadataChecker::UNIQUE_REF_MAX_LENGTH }
    let(:checker) { described_class.new }
    let(:valid_params) { { official_document_type: "unofficial" } }

    it "returns no issues if there are none" do
      issues = checker.pre_update_issues(valid_params)
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
        issues = checker.pre_update_issues(valid_params.merge(isbn: valid_isbn))
        expect(issues).to be_empty
      end
    end

    it "returns an issue when the official document type is blank" do
      issues = checker.pre_update_issues({})
      expect(issues).to have_issue(:file_attachment_official_document_type, :blank)
    end

    %w(command act).each do |type|
      it "returns an issue when a numbered #{type} paper has no number" do
        issues = checker.pre_update_issues(official_document_type: "#{type}_paper")
        expect(issues).to have_issue(:"file_attachment_#{type}_paper_number", :blank)
      end
    end
  end
end
