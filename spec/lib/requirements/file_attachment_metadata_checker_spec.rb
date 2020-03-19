RSpec.describe Requirements::FileAttachmentMetadataChecker do
  describe "#pre_update_issues" do
    let(:max_length) { Requirements::FileAttachmentMetadataChecker::UNIQUE_REF_MAX_LENGTH }

    it "returns no issues if there are none" do
      unique_reference = "z" * max_length
      issues = described_class.new(unique_reference: unique_reference).pre_update_issues
      expect(issues).to be_empty
    end

    it "returns unique_reference issues when the unique unique_reference is too long" do
      unique_reference = "z" * (max_length + 1)
      issues = described_class.new(unique_reference: unique_reference).pre_update_issues

      expect(issues).to have_issue(:file_attachment_unique_reference,
                                   :too_long,
                                   max_length: max_length)
    end
  end
end
