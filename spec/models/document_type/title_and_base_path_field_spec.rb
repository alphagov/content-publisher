RSpec.describe DocumentType::TitleAndBasePathField do
  describe "#payload" do
    it "returns a hash with title and routing attributes" do
      edition = build(:edition, title: "Some title", base_path: "/foo/bar/baz")
      payload = DocumentType::TitleAndBasePathField.new.payload(edition)

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
      params = ActionController::Parameters.new(title: "  a title")
      allow(GenerateBasePathService).to receive(:call).with(edition, title: "a title").and_return("base path")
      updater_params = DocumentType::TitleAndBasePathField.new.updater_params(edition, params)
      expect(updater_params).to eq(title: "a title", base_path: "base path")
    end
  end

  describe "#pre_preview_issues" do
    let(:edition) { build :edition }

    it "returns no issues if there are none" do
      issues = DocumentType::TitleAndBasePathField.new.pre_preview_issues(edition)
      expect(issues).to be_empty
    end

    it "returns an issue if there is no title" do
      edition = build :edition, title: nil
      issues = DocumentType::TitleAndBasePathField.new.pre_preview_issues(edition)
      expect(issues).to have_issue(:title, :blank, styles: %i[form summary])
    end

    it "returns an issue if the title is too long" do
      max_length = DocumentType::TitleAndBasePathField::TITLE_MAX_LENGTH
      edition = build :edition, title: "a" * (max_length + 1)
      issues = DocumentType::TitleAndBasePathField.new.pre_preview_issues(edition)
      expect(issues).to have_issue(:title, :too_long, styles: %i[form summary], max_length: max_length)
    end

    it "returns an issue if the title has newlines" do
      edition = build :edition, title: "a\nb"
      issues = DocumentType::TitleAndBasePathField.new.pre_preview_issues(edition)
      expect(issues).to have_issue(:title, :multiline, styles: %i[form summary])
    end
  end

  describe "pre_update_issues" do
    let(:edition) { build :edition }

    before do
      stub_publishing_api_has_lookups(edition.base_path => nil)
    end

    it "returns no issues if there are none" do
      params = { title: edition.title }
      issues = DocumentType::TitleAndBasePathField.new.pre_update_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns any pre_preview_issues" do
      params = { title: nil }
      issues = DocumentType::TitleAndBasePathField.new.pre_update_issues(edition, params)
      expect(issues).to have_issue(:title, :blank, styles: %i[form summary])
    end

    it "returns no issues if the document owns the path" do
      stub_publishing_api_has_lookups(edition.base_path => edition.content_id)
      params = { title: edition.title, base_path: edition.base_path }
      issues = DocumentType::TitleAndBasePathField.new.pre_update_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns an issue if the base_path conflicts" do
      stub_publishing_api_has_lookups(edition.base_path => SecureRandom.uuid)
      params = { title: edition.title, base_path: edition.base_path }
      issues = DocumentType::TitleAndBasePathField.new.pre_update_issues(edition, params)
      expect(issues).to have_issue(:title, :conflict, styles: %i[form summary])
    end

    it "returns no issues when the Publishing API is down" do
      stub_publishing_api_isnt_available
      params = { title: edition.title, base_path: edition.base_path }
      issues = DocumentType::TitleAndBasePathField.new.pre_update_issues(edition, params)
      expect(issues.items_for(:title)).to be_empty
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues" do
      edition = build :edition
      issues = DocumentType::TitleAndBasePathField.new.pre_publish_issues(edition)
      expect(issues).to be_empty
    end
  end
end
