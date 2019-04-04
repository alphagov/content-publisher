# frozen_string_literal: true

RSpec.describe ContentDataUrl do
  describe "#url" do
    it "returns a Content Data Admin data page URL for the document" do
      document = build(:document, :with_live_edition)
      base_path = document.current_edition.base_path
      data_page_url = ContentDataUrl.new(document).url

      expect(data_page_url).to eq("https://content-data-admin.test.gov.uk/metrics#{base_path}")
    end
  end
end
