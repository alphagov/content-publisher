# frozen_string_literal: true

RSpec.describe DraftAssetCleanupService do
  describe "#call" do
    context "when the previous revision has draft assets that aren't used" do
      it "deletes the assets that aren't used" do
        image_revision = create(:image_revision, :on_asset_manager, state: :draft)
        preceding_revision = create(:revision, image_revisions: [image_revision])
        current_revision = create(:revision, preceded_by: preceding_revision)
        edition = create(:edition, revision: current_revision)

        request = stub_asset_manager_deletes_any_asset

        DraftAssetCleanupService.new.call(edition)

        expect(request).to have_been_requested.at_least_once
        expect(image_revision.assets.map(&:state).uniq).to match(%w[absent])
      end
    end

    context "when the previous revision has assets that are used on the current revision" do
      it "doesn't change the assets" do
        image_revision = create(:image_revision, :on_asset_manager, state: :draft)
        preceding_revision = create(:revision, image_revisions: [image_revision])
        current_revision = create(:revision,
                                  image_revisions: [image_revision],
                                  preceded_by: preceding_revision)
        edition = create(:edition, revision: current_revision)

        request = stub_asset_manager_deletes_any_asset

        DraftAssetCleanupService.new.call(edition)

        expect(request).not_to have_been_requested
        expect(image_revision.assets.map(&:state).uniq).to match(%w[draft])
      end
    end

    context "when the previous revision has assets that are live" do
      it "doesn't change the assets" do
        image_revision = create(:image_revision, :on_asset_manager, state: :live)
        preceding_revision = create(:revision, image_revisions: [image_revision])
        current_revision = create(:revision, preceded_by: preceding_revision)
        edition = create(:edition, revision: current_revision)

        request = stub_asset_manager_deletes_any_asset

        DraftAssetCleanupService.new.call(edition)

        expect(request).not_to have_been_requested
        expect(image_revision.assets.map(&:state).uniq).to match(%w[live])
      end
    end

    context "when there is no previous revision" do
      it "doesn't blow up" do
        revision = create(:revision, preceded_by: nil)
        edition = create(:edition, revision: revision)

        expect { DraftAssetCleanupService.new.call(edition) }
          .not_to raise_error
      end
    end

    context "when assets to remove are not on asset manager" do
      it "marks the assets as absent" do
        image_revision = create(:image_revision, :on_asset_manager, state: :draft)
        preceding_revision = create(:revision, image_revisions: [image_revision])
        current_revision = create(:revision, preceded_by: preceding_revision)
        edition = create(:edition, revision: current_revision)

        stub_asset_manager_deletes_any_asset.to_return(status: 404)

        DraftAssetCleanupService.new.call(edition)

        expect(image_revision.assets.map(&:state).uniq).to match(%w[absent])
      end
    end
  end
end
