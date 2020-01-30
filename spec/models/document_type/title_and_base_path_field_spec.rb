# frozen_string_literal: true

RSpec.describe DocumentType::TitleAndBasePathField do
  describe "#payload" do
    it "returns a hash with title and routing attributes" do
      edition = build(:edition, title: "Some title", base_path: "/foo/bar/baz")
      payload = subject.payload(edition)

      expect(payload).to eq(
        title: "Some title",
        base_path: "/foo/bar/baz",
        routes: [{ path: "/foo/bar/baz", type: "exact" }],
      )
    end
  end

  describe "#updater_params" do
    it "returns a hash of the stripped title and base_path" do
      edition = build :edition
      params = ActionController::Parameters.new(revision: { title: "  a title" })
      allow(GenerateBasePathService).to receive(:call) { "base path" }
      updater_params = subject.updater_params(edition, params)
      expect(updater_params).to eq(title: "a title", base_path: "base path")
    end
  end

  describe "#pre_preview_issues" do
    let(:edition) { build :edition }

    it "returns no issues if there are none" do
      issues = subject.pre_preview_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue if there is no title" do
      revision = build :revision, title: nil
      issues = subject.pre_preview_issues(edition, revision)
      expect(issues).to have_issue(:title, :blank, styles: %i[form summary])
    end

    it "returns an issue if the title is too long" do
      edition = build :edition
      max_length = DocumentType::TitleAndBasePathField::TITLE_MAX_LENGTH
      revision = build :revision, title: "a" * (max_length + 1)
      issues = subject.pre_preview_issues(edition, revision)
      expect(issues).to have_issue(:title, :too_long, styles: %i[form summary], max_length: max_length)
    end

    it "returns an issue if the title has newlines" do
      edition = build :edition
      revision = build :revision, title: "a\nb"
      issues = subject.pre_preview_issues(edition, revision)
      expect(issues).to have_issue(:title, :multiline, styles: %i[form summary])
    end
  end

  describe "pre_update_issues" do
    let(:edition) do
      build :edition, document_type_id: build(:document_type, check_path_conflict: true).id
    end

    before do
      stub_publishing_api_has_lookups(edition.base_path => nil)
    end

    it "returns no issues if there are none" do
      issues = subject.pre_update_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns any pre_preview_issues" do
      revision = build :revision, title: nil
      issues = subject.pre_update_issues(edition, revision)
      expect(issues).to have_issue(:title, :blank, styles: %i[form summary])
    end

    it "returns no issues if the document owns the path" do
      stub_publishing_api_has_lookups(edition.base_path => edition.content_id)
      issues = subject.pre_update_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue if the base_path conflicts" do
      stub_publishing_api_has_lookups(edition.base_path => SecureRandom.uuid)
      issues = subject.pre_update_issues(edition, edition.revision)
      expect(issues).to have_issue(:title, :conflict, styles: %i[form summary])
    end

    it "returns no issues when the Publishing API is down" do
      stub_publishing_api_isnt_available
      issues = subject.pre_update_issues(edition, edition.revision)
      expect(issues.items_for(:title)).to be_empty
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues" do
      edition = build :edition
      issues = subject.pre_update_issues(edition, edition.revision)
      expect(issues).to be_empty
    end
  end
end
