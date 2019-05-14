# frozen_string_literal: true

RSpec.describe ContentDataUrl do
  include ActiveSupport::Testing::TimeHelpers

  let(:document) { build(:document, :with_live_edition, first_published_at: 2.days.ago) }
  let(:beta_partner) { build(:user, organisation_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9") }

  describe "#url" do
    it "returns a Content Data Admin data page URL for the document" do
      base_path = document.current_edition.base_path
      data_page_url = ContentDataUrl.new(document).url

      expect(data_page_url).to eq("https://content-data.test.gov.uk/metrics#{base_path}")
    end
  end

  describe "#displayable" do
    it "returns true if the user is part of a Content Data beta partner organisation and edition was published before yesterday" do
      expect(ContentDataUrl.new(document).displayable?(beta_partner)).to be true
    end

    it "returns true if the user has pre-release permission and edition was published before yesterday" do
      pre_release_user = build(:user, permissions: [User::PRE_RELEASE_FEATURES_PERMISSION])
      expect(ContentDataUrl.new(document).displayable?(pre_release_user)).to be true
    end

    it "returns false if the user is not part of a Content Data beta partner organisation" do
      user = build(:user, organisation_content_id: SecureRandom.uuid)
      expect(ContentDataUrl.new(document).displayable?(user)).to be false
    end

    it "returns false if the document was first published today" do
      document.first_published_at = Time.current
      document.save!

      expect(ContentDataUrl.new(document).displayable?(beta_partner)).to be false
    end

    it "returns false if the document was first published yesterday and it is currently before 9am" do
      document.first_published_at = Time.current.yesterday
      document.save!
      before_nine_am_today = Time.current.change(hour: 8, min: 59)

      travel_to(before_nine_am_today) do
        expect(ContentDataUrl.new(document).displayable?(beta_partner)).to be false
      end
    end

    it "returns true if the document was first published yesterday and it is currently 9am" do
      document.first_published_at = Time.current.yesterday
      document.save!
      nine_am_today = Time.current.change(hour: 9)

      travel_to(nine_am_today) do
        expect(ContentDataUrl.new(document).displayable?(beta_partner)).to be true
      end
    end
  end
end
