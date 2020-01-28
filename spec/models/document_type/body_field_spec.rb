# frozen_string_literal: true

RSpec.describe DocumentType::BodyField do
  describe "#payload" do
    it "returns a hash with 'body' converted to Govspeak" do
      edition = build(:edition, contents: { body: "Hey **buddy**!" })
      payload = subject.payload(edition)
      expect(payload[:details][:body]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end

  describe "#updater_params" do
    it "returns a hash of the body" do
      edition = build :edition
      params = ActionController::Parameters.new(revision: { contents: { body: "body" } })
      updater_params = subject.updater_params(edition, params)
      expect(updater_params).to eq(contents: { body: "body" })
    end
  end

  describe "#pre_preview_issues" do
    it "returns no issues when there are none" do
      edition = build :edition, contents: { body: "alert('hi')" }
      issues = subject.pre_preview_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue if the a govspeak field contains forbidden HTML" do
      edition = build :edition, contents: { body: "<script>alert('hi')</script>" }
      issues = subject.pre_preview_issues(edition, edition.revision)
      expect(issues).to have_issue(:body, :invalid_govspeak, styles: %i[form summary])
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues when there are none" do
      edition = build :edition, contents: { body: "alert('hi')" }
      issues = subject.pre_publish_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue when the body is empty" do
      edition = build :edition, contents: { body: " " }
      issues = subject.pre_publish_issues(edition, edition.revision)
      expect(issues).to have_issue(:body, :blank, styles: %i[form summary])
    end
  end
end
