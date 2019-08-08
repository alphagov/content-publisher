# frozen_string_literal: true

RSpec.describe FileAttachments::PreviewInteractor do
  describe ".call" do
    let(:file_attachment) { create :file_attachment }
    let(:edition) { create :edition }

    let(:params) do
      { document: edition.document.to_param, file_attachment_id: file_attachment.id }
    end

    before do
      allow(PreviewAssetService).to receive(:call)
    end

    context "when the asset is present on Asset Manager" do
      let(:attachment_revision) do
        create :file_attachment_revision, :on_asset_manager, file_attachment: file_attachment
      end

      let(:asset) { attachment_revision.asset }

      before do
        edition.file_attachment_revisions << attachment_revision
      end

      it "returns the asset when it's available to download" do
        stub_asset_manager_has_an_asset(asset.asset_manager_id, "state": "uploaded")
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.can_preview).to be_truthy
        expect(result.api_error).to be_falsey
      end

      it "returns a can_preview flag when the asset is unavailable" do
        stub_asset_manager_has_an_asset(asset.asset_manager_id, "state": "unscanned")
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.can_preview).to be_falsey
      end

      it "returns an api_error flag when Asset Manager is down" do
        stub_asset_manager_isnt_available
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.api_error).to be_truthy
      end
    end

    context "when the asset is absent from Asset Manager" do
      let(:attachment_revision) do
        create :file_attachment_revision, file_attachment: file_attachment
      end

      before do
        edition.file_attachment_revisions << attachment_revision
      end

      it "uploads the asset" do
        expect(PreviewAssetService).to receive(:call)
        FileAttachments::PreviewInteractor.call(params: params)
      end

      it "returns a can_preview flag" do
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.can_preview).to be_falsey
      end

      it "returns an api_error flag when Asset Manager is down" do
        allow(PreviewAssetService).to receive(:call).and_raise(GdsApi::BaseError)
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.api_error).to be_truthy
      end
    end
  end
end
