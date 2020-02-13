RSpec.describe WhitehallImporter::IntegrityChecker::BodyTextCheck do
  describe "#sufficiently_similar?" do
    it "retuns true if the proposed payload matches" do
      integrity_check = described_class.new("Some text", "Some text")
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns false when the body text doesn't match" do
      integrity_check = described_class.new("Some text", "Some different text")
      expect(integrity_check.sufficiently_similar?).to be false
    end
  end
end
