# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    let(:asset_id) { "847150" }
    let(:asset) do
      build(:whitehall_imported_asset,
            :image,
            original_asset_url: "https://asset-manager.gov.uk/blah/#{asset_id}/foo.jpg")
    end
    let(:whitehall_import) { build(:whitehall_import, assets: [asset]) }

    before :each do
      stub_any_asset_manager_call
    end

    it "should take a WhitehallImport record as an argument" do
      expect { described_class.call(whitehall_import) }.not_to raise_error
    end

    it "should mark each asset as processing before marking as processed" do
      expect(asset).to receive(:update!).with(state: "processing").once.ordered
      expect(asset).to receive(:update!).with(state: "processed").once.ordered
      described_class.call(whitehall_import)
    end

    it "should redirect live images" do
      allow(asset.image_revision.asset("960")).to receive(:state).and_return("live")
      update_asset_request = stub_asset_manager_update_asset(
        asset_id,
        redirect_url: asset.image_revision.asset_url("960"),
      )

      described_class.call(whitehall_import)
      expect(update_asset_request).to have_been_requested
    end

    it "should delete draft images" do
      allow(asset.image_revision.asset("960")).to receive(:state).and_return("draft")
      delete_asset_request = stub_asset_manager_delete_asset("847150")

      described_class.call(whitehall_import)
      expect(delete_asset_request).to have_been_requested
    end

    it "should delete variants of draft images" do
      allow(asset.image_revision.asset("960")).to receive(:state).and_return("draft")
      delete_request1 = stub_asset_manager_delete_asset("847151") # s300
      delete_request2 = stub_asset_manager_delete_asset("847152") # s960

      described_class.call(whitehall_import)
      expect(delete_request1).to have_been_requested
      expect(delete_request2).to have_been_requested
    end

    context "assets are attachments" do
      let(:asset) do
        build(:whitehall_imported_asset,
              :file_attachment,
              original_asset_url: "https://asset-manager.gov.uk/blah/#{asset_id}/foo.pdf")
      end

      it "should redirect live attachments" do
        allow(asset.file_attachment_revision.asset).to receive(:state).and_return("live")
        update_asset_request = stub_asset_manager_update_asset(
          asset_id,
          redirect_url: asset.file_attachment_revision.asset_url,
        )

        described_class.call(whitehall_import)
        expect(update_asset_request).to have_been_requested
      end

      it "should delete live attachment variants" do
        allow(asset.file_attachment_revision.asset).to receive(:state).and_return("live")
        delete_request = stub_asset_manager_delete_asset("847151") # thumbnail

        described_class.call(whitehall_import)
        expect(delete_request).to have_been_requested
      end

      it "should delete draft attachments" do
        allow(asset.file_attachment_revision.asset).to receive(:state).and_return("draft")
        delete_asset_request = stub_asset_manager_delete_asset(asset_id)

        described_class.call(whitehall_import)
        expect(delete_asset_request).to have_been_requested
      end

      it "should delete variants of draft attachments" do
        allow(asset.file_attachment_revision.asset).to receive(:state).and_return("draft")
        delete_request = stub_asset_manager_delete_asset("847151") # thumbnail

        described_class.call(whitehall_import)
        expect(delete_request).to have_been_requested
      end
    end
  end
end
