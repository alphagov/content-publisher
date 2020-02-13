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

  describe "#pre_update_issues" do
    let(:edition) { build :edition }

    it "returns no issues when there are none" do
      params = { contents: { body: "alert('hi')" } }
      issues = described_class.new.pre_update_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns an issue if the a govspeak field contains forbidden HTML" do
      params = { contents: { body: "<script>alert('hi')</script>" } }
      issues = described_class.new.pre_update_issues(edition, params)
      expect(issues).to have_issue(:body, :invalid_govspeak, styles: %i[form summary])
    end
  end

  describe "#pre_preview_issues" do
    it "delegates to #pre_update_issues" do
      edition = build :edition, contents: { body: "body" }
      params = { contents: { body: edition.contents["body"] } }
      field = described_class.new
      expect(field).to receive(:pre_update_issues).with(edition, params)
      field.pre_preview_issues(edition)
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues when there are none" do
      edition = build :edition, contents: { body: "alert('hi')" }
      issues = described_class.new.pre_publish_issues(edition)
      expect(issues).to be_empty
    end

    it "returns an issue when the body is empty" do
      edition = build :edition, contents: { body: " " }
      issues = described_class.new.pre_publish_issues(edition)
      expect(issues).to have_issue(:body, :blank, styles: %i[form summary])
    end
  end
end
