RSpec.describe EditionUpdater do
  before do
    stub_any_publishing_api_put_content
    allow(EditDraftEditionService).to receive(:call).and_call_original
    allow(FailsafeDraftPreviewService).to receive(:call).and_call_original
  end

  describe ".call" do
    let(:edition) { create(:edition, locale: "en") }
    let(:title) { "The quick brown fox jumps over a lazy dog" }

    it "delegates to the EditDraftEditionService to record the edit" do
      user = create(:user)
      described_class.call(edition.content_id,
                           user_email: user.email) do |_, updater|
        updater.assign(title:)
      end

      expect(EditDraftEditionService)
        .to have_received(:call)
        .with(edition, user, a_hash_including(:revision))
    end

    it "delegates to the FailsafeDraftPreviewService to create a preview" do
      described_class.call(edition.content_id) do |_, updater|
        updater.assign(title:)
      end

      expect(FailsafeDraftPreviewService).to have_received(:call).with(edition)
    end

    it "updates an edition" do
      described_class.call(edition.content_id) do |_, updater|
        updater.assign(title:)
      end

      expect(edition.reload.title).to eq(title)
    end

    it "updates an internationalized edition" do
      chinese_locale = "cn"
      chinese_edition = create(:edition, locale: chinese_locale)
      chinese_title = "敏捷的棕色狐狸跳过了一只懒狗"

      described_class.call(chinese_edition.content_id,
                           locale: chinese_locale) do |_, updater|
        updater.assign(title: chinese_title)
      end

      expect(chinese_edition.reload.title).to eq(chinese_title)
    end

    it "raises an error if the edition is not editable" do
      published_edition = create(:edition, :published, locale: "en")

      expect {
        described_class.call(published_edition.content_id) do |_, updater|
          updater.assign(title:)
        end
      }.to raise_error("Edition must be editable")
    end

    it "raises an error if the edition has not been updated" do
      expect {
        described_class.call(edition.content_id) do |_, updater|
          updater.assign(title: edition.title)
        end
      }.to raise_error("Expected an updated revision")
    end
  end
end
