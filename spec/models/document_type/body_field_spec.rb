RSpec.describe DocumentType::BodyField do
  describe "#payload" do
    it "returns a hash with 'body' converted to Govspeak" do
      edition = build(:edition, contents: { body: "Hey **buddy**!" })
      payload = described_class.new.payload(edition)
      expect(payload[:details][:body]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end

  describe "#updater_params" do
    it "returns a hash of the body" do
      edition = build :edition
      params = ActionController::Parameters.new(body: "body")
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(contents: { body: "body" })
    end
  end

  describe "#form_issues" do
    let(:edition) { build :edition }

    it "returns no issues when there are none" do
      params = { contents: { body: "alert('hi')" } }
      issues = described_class.new.form_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns an issue if the a govspeak field contains forbidden HTML" do
      params = { contents: { body: "<script>alert('hi')</script>" } }
      issues = described_class.new.form_issues(edition, params)
      expect(issues).to have_issue(:body, :invalid_govspeak)
    end
  end

  describe "#preview_issues" do
    it "returns no issues" do
      edition = build :edition, contents: { body: "body" }
      issues = described_class.new.preview_issues(edition)
      expect(issues).to be_empty
    end
  end

  describe "#publish_issues" do
    it "returns no issues when there are none" do
      edition = build :edition, contents: { body: "alert('hi')" }
      issues = described_class.new.publish_issues(edition)
      expect(issues).to be_empty
    end

    it "returns an issue when the body is empty" do
      edition = build :edition, contents: { body: " " }
      issues = described_class.new.publish_issues(edition)
      expect(issues).to have_issue(:body, :blank, styles: %i[summary])
    end
  end
end
