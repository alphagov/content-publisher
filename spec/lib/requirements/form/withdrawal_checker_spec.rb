RSpec.describe Requirements::Form::WithdrawalChecker do
  describe ".call" do
    let(:edition) { build(:edition) }

    it "returns no issues if there are none" do
      explanation = SecureRandom.alphanumeric
      issues = described_class.call(edition, explanation)
      expect(issues).to be_empty
    end

    it "returns an issue if there is no public explanation" do
      issues = described_class.call(edition, nil)
      expect(issues).to have_issue(:public_explanation, :blank)
    end

    it "returns an issue if there is invalid govspeak in the public explanation" do
      explanation = "<script>alert('123')</script>"
      issues = described_class.call(edition, explanation)
      expect(issues).to have_issue(:public_explanation, :invalid_govspeak)
    end
  end
end
