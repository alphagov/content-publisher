# frozen_string_literal: true

RSpec.describe PublishAssetService do
  describe "#publish_assets" do
    it "publishes the draft assets and marks them as live" do
      image_revision = create(:image_revision, :on_asset_manager, state: :draft)
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :draft)
      edition = create(:edition,
                       :publishable,
                       file_attachment_revisions: [file_attachment_revision],
                       image_revisions: [image_revision])

      request = stub_asset_manager_updates_any_asset
      PublishAssetService.new.publish_assets(edition, nil)
      expect(image_revision.assets.map(&:state).uniq).to eq(%w[live])
      expect(file_attachment_revision.asset).to be_live
      expect(request).to have_been_requested.at_least_once
    end

    it "doesn't republish the assets that are already live" do
      image_revision = create(:image_revision, :on_asset_manager, state: :live)
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
      live_edition = create(:edition,
                            :published,
                            file_attachment_revisions: [file_attachment_revision],
                            image_revisions: [image_revision],
                            current: false)
      edition = create(:edition,
                       :publishable,
                       file_attachment_revisions: [file_attachment_revision],
                       image_revisions: [image_revision],
                       document: live_edition.document)

      request = stub_any_asset_manager_call
      PublishAssetService.new.publish_assets(edition, live_edition)
      expect(request).to_not have_been_requested
    end

    it "raises an error if an asset is marked as absent" do
      image_revision = create(:image_revision, :on_asset_manager, state: :absent)
      edition = create(:edition,
                       :publishable,
                       image_revisions: [image_revision])

      expect { PublishAssetService.new.publish_assets(edition, nil) }.to raise_error("Expected asset to be on asset manager")
    end

    it "removes an asset not used by the current edition" do
      image_revision_to_remove = create(:image_revision, :on_asset_manager, state: :live)
      file_attachment_revision_to_remove = create(:file_attachment_revision, :on_asset_manager, state: :live)
      live_edition = create(:edition,
                            :published,
                            image_revisions: [image_revision_to_remove],
                            file_attachment_revisions: [file_attachment_revision_to_remove],
                            current: false)
      edition = create(:edition,
                       :publishable,
                       image_revisions: [],
                       file_attachment_revisions: [],
                       document: live_edition.document)

      delete_request = stub_asset_manager_deletes_any_asset

      PublishAssetService.new.publish_assets(edition, live_edition)
      expect(image_revision_to_remove.assets.map(&:state).uniq).to eq(%w[absent])
      expect(file_attachment_revision_to_remove.asset).to be_absent
      expect(delete_request).to have_been_requested.at_least_once
    end
  end

  it "retains assets used by the current and live edition" do
    image_revision_to_keep = create(:image_revision, :on_asset_manager, state: :live)
    file_attachment_revision_to_keep = create(:file_attachment_revision, :on_asset_manager, state: :live)
    live_edition = create(:edition,
                          :published,
                          image_revisions: [image_revision_to_keep],
                          file_attachment_revisions: [file_attachment_revision_to_keep],
                          current: false)
    edition = create(:edition,
                     :publishable,
                     image_revisions: [image_revision_to_keep],
                     file_attachment_revisions: [file_attachment_revision_to_keep],
                     document: live_edition.document)

    PublishAssetService.new.publish_assets(edition, live_edition)

    expect(image_revision_to_keep.assets.map(&:state).uniq).to eq(%w[live])
    expect(file_attachment_revision_to_keep.asset).to be_live
  end

  it "redirects and supersedes the old asset to the new asset" do
    old_image_revision = create(:image_revision, :on_asset_manager, state: :live)
    old_file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
    new_file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, file_attachment: old_file_attachment_revision.file_attachment)
    new_image_revision = create(:image_revision, :on_asset_manager, image: old_image_revision.image)

    live_edition = create(:edition,
                          :published,
                          image_revisions: [old_image_revision],
                          file_attachment_revisions: [old_file_attachment_revision],
                          current: false)
    edition = create(:edition,
                     :publishable,
                     image_revisions: [new_image_revision],
                     file_attachment_revisions: [new_file_attachment_revision],
                     document: live_edition.document)

    request = stub_asset_manager_updates_any_asset

    PublishAssetService.new.publish_assets(edition, live_edition)

    expect(old_image_revision.assets.map(&:state).uniq).to eq(%w[superseded])
    expect(old_file_attachment_revision.asset).to be_superseded
    expect(request).to have_been_requested.at_least_once
  end
end
