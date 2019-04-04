# frozen_string_literal: true

RSpec.describe ContentDataUrl do
  let(:document) { build(:document, :with_live_edition) }

  describe "#url" do
    it "returns a Content Data Admin data page URL for the document" do
      base_path = document.current_edition.base_path
      data_page_url = ContentDataUrl.new(document).url

      expect(data_page_url).to eq("https://content-data-admin.test.gov.uk/metrics#{base_path}")
    end
  end

  describe "#displayable" do
    it "returns true if the user is part of a Content Data beta partner organisation" do
      user = build(:user, organisation_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9")
      expect(ContentDataUrl.new(document).displayable?(user)).to be true
    end

    it "returns false if the user is not part of a Content Data beta partner organisation" do
      user = build(:user, organisation_content_id: SecureRandom.uuid)
      expect(ContentDataUrl.new(document).displayable?(user)).to be false
    end
  end
end
