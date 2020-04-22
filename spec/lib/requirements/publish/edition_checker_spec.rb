RSpec.describe Requirements::Publish::EditionChecker do
  describe ".issues" do
    it "delegates to lower-level checkers" do
      edition = build :edition
      low_level_issues = Requirements::CheckerIssues.new(%i[issue])
      checkers = Requirements::Publish::EditionChecker::CHECKERS

      checkers.each do |checker|
        allow(checker)
          .to receive(:call)
          .with(edition)
          .and_return(low_level_issues)
      end

      issues = described_class.call(edition)
      expect(issues.to_a).to eq(checkers.map { :issue })
    end
  end
end
