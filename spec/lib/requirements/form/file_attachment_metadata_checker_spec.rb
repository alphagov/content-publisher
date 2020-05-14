RSpec.describe Requirements::Form::FileAttachmentMetadataChecker do
  describe ".call" do
    let(:max_length) { Requirements::Form::FileAttachmentMetadataChecker::UNIQUE_REF_MAX_LENGTH }
    let(:valid_params) { { official_document_type: "unofficial" } }

    it "returns no issues if there are none" do
      issues = described_class.call(valid_params)
      expect(issues).to be_empty
    end

    it "returns an issue when the unique_reference is too long" do
      unique_reference = "z" * (max_length + 1)
      issues = described_class.call(unique_reference: unique_reference)

      expect(issues).to have_issue(
        :file_attachment_unique_reference,
        :too_long,
        max_length: max_length,
      )
    end

    [
      "invalid",
      "9788--0631625",
      "9991a9010599938",
      "0-9722051-1-F",
      "ISBN 9788700631625",
    ].each do |invalid_isbn|
      it "returns an issue for invalid isbn #{invalid_isbn}" do
        issues = described_class.call(isbn: invalid_isbn)
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
        issues = described_class.call(valid_params.merge(isbn: valid_isbn))
        expect(issues).to be_empty
      end
    end

    it "returns an issue when the official document type is blank" do
      issues = described_class.call({})
      expect(issues).to have_issue(:file_attachment_official_document_type, :blank)
    end

    %w[command act].each do |type|
      it "returns an issue when a numbered #{type} paper has no number" do
        issues = described_class.call(official_document_type: "#{type}_paper")
        expect(issues).to have_issue(:"file_attachment_#{type}_paper_number", :blank)
      end
    end

    [
      "C. 123",
      "Cd. 123-I",
      "Cmd. 123-IV",
      "Cmnd. 123-VIII",
      "Cm. 123",
      "CP 1",
    ].each do |valid_number|
      it "returns no issues for valid command paper number #{valid_number}" do
        params = { official_document_type: "command_paper", command_paper_number: valid_number }
        issues = described_class.call(valid_params.merge(params))
        expect(issues).to be_empty
      end
    end

    [
      "NA 123", # bad prefix
      "C 123", # no dot
      "C123", # no space
      "CM. 123", # prefix casing
      "CP. 123", # prefix casing
      "C. 123-i", # lower case
      "C. 123VIII", # no dash
    ].each do |valid_number|
      it "returns an issue for invalid command paper number #{valid_number}" do
        params = { official_document_type: "command_paper", command_paper_number: valid_number }
        issues = described_class.call(params)
        expect(issues).to have_issue(:file_attachment_command_paper_number, :invalid)
      end
    end

    %w[
      123
      123-VIII
    ].each do |valid_number|
      it "returns no issues for valid act paper number #{valid_number}" do
        params = { official_document_type: "act_paper", act_paper_number: valid_number }
        issues = described_class.call(valid_params.merge(params))
        expect(issues).to be_empty
      end
    end

    [
      "123-i", # lower case
      "123VIII", # no dash
    ].each do |valid_number|
      it "returns an issue for invalid act paper number #{valid_number}" do
        params = { official_document_type: "act_paper", act_paper_number: valid_number }
        issues = described_class.call(params)
        expect(issues).to have_issue(:file_attachment_act_paper_number, :invalid)
      end
    end
  end
end
