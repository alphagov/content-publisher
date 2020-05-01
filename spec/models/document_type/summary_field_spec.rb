RSpec.describe DocumentType::SummaryField do
  describe "#payload" do
    it "returns a hash with a 'description' / summary" do
      edition = build(:edition, summary: "document summary")
      payload = described_class.new.payload(edition)
      expect(payload).to eq(description: "document summary")
    end
  end

  describe "#updater_params" do
    it "returns a hash of the stripped summary" do
      edition = build :edition
      params = ActionController::Parameters.new(summary: "  summary")
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(summary: "summary")
    end
  end

  describe "#form_issues" do
    let(:edition) { build :edition }

    it "returns no issues if there are none" do
      params = { summary: edition.summary }
      issues = described_class.new.form_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns an issue if the summary is too long" do
      max_length = DocumentType::SummaryField::SUMMARY_MAX_LENGTH
      params = { summary: "a" * (max_length + 1) }
      issues = described_class.new.form_issues(edition, params)
      expect(issues).to have_issue(:summary, :too_long, max_length: max_length)
    end

    it "returns an issue if the summary has newlines" do
      params = { summary: "a\nb" }
      issues = described_class.new.form_issues(edition, params)
      expect(issues).to have_issue(:summary, :multiline)
    end
  end

  describe "#preview_issues" do
    let(:edition) { build :edition }

    it "returns no issues" do
      issues = described_class.new.preview_issues(edition)
      expect(issues).to be_empty
    end
  end

  describe "#publish_issues" do
    let(:edition) { build :edition, summary: "a summary" }

    it "returns no issues if there are none" do
      issues = described_class.new.publish_issues(edition)
      expect(issues).to be_empty
    end

    it "returns an issue if the summary is blank" do
      edition = build :edition, summary: "  "
      issues = described_class.new.publish_issues(edition)
      expect(issues).to have_issue(:summary, :blank, styles: %i[summary])
    end
  end
end
