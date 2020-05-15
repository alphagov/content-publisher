RSpec.describe DeleteDraftAssetsService do
  describe ".call" do
    it "attempts to delete an edition's assets from asset manager" do
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
      image_revision = create(:image_revision, :on_asset_manager)
      edition = create(
        :edition,
        lead_image_revision: image_revision,
        file_attachment_revisions: [file_attachment_revision],
      )

      delete_request = stub_asset_manager_deletes_any_asset

      described_class.call(edition)

      expect(delete_request).to have_been_requested.at_least_once
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
      expect(file_attachment_revision.reload.asset).to be_absent
    end

    it "copes if an asset is not in Asset Manager" do
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
      edition = create(
        :edition,
        file_attachment_revisions: [file_attachment_revision],
      )
      stub_any_asset_manager_call.to_return(status: 404)

      described_class.call(edition)

      expect(file_attachment_revision.reload.asset).to be_absent
    end

    it "skips any live assets from asset manager" do
      image_revision = create(:image_revision, :on_asset_manager, state: :live)
      edition = create(:edition, lead_image_revision: image_revision)
      delete_request = stub_asset_manager_deletes_any_asset

      described_class.call(edition)

      expect(delete_request).not_to have_been_requested
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[live])
    end
  end
end
