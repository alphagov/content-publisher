# frozen_string_literal: true

RSpec.describe ContentDataUrl do
  include ActiveSupport::Testing::TimeHelpers

  let(:document) { build(:document, :with_live_edition, first_published_at: 2.days.ago) }

  describe "#url" do
    it "returns a Content Data Admin data page URL for the document" do
      base_path = document.current_edition.base_path
      data_page_url = ContentDataUrl.new(document).url

      expect(data_page_url).to eq("https://content-data.test.gov.uk/metrics#{base_path}")
    end
  end

  describe "#displayable" do
    it "returns true if the edition was published before yesterday" do
      expect(ContentDataUrl.new(document).displayable?).to be true
    end

    it "returns false if the document was first published today" do
      document.first_published_at = Time.current
      document.save!

      expect(ContentDataUrl.new(document).displayable?).to be false
    end

    it "returns false if the document was first published yesterday and it is currently before 9am" do
      document.first_published_at = Time.current.yesterday
      document.save!
      before_nine_am_today = Time.current.change(hour: 8, min: 59)

      travel_to(before_nine_am_today) do
        expect(ContentDataUrl.new(document).displayable?).to be false
      end
    end

    it "returns true if the document was first published yesterday and it is currently 9am" do
      document.first_published_at = Time.current.yesterday
      document.save!
      nine_am_today = Time.current.change(hour: 9)

      travel_to(nine_am_today) do
        expect(ContentDataUrl.new(document).displayable?).to be true
      end
    end
  end
end
