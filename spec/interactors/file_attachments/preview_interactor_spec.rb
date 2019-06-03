# frozen_string_literal: true

RSpec.describe FileAttachments::PreviewInteractor do
  describe ".call" do
    let(:file_attachment) { create :file_attachment }
    let(:edition) { create :edition }

    let(:params) do
      { document: edition.document.to_param, file_attachment_id: file_attachment.id }
    end

    let(:preview_asset_service) do
      instance_double(PreviewAssetService)
    end

    before do
      allow(PreviewAssetService).to receive(:new) { preview_asset_service }
    end

    context "when the asset is present on Asset Manager" do
      before do
        attachment_revision = create :file_attachment_revision, :on_asset_manager, file_attachment: file_attachment
        edition.file_attachment_revisions << attachment_revision
      end

      it "returns the asset when it's available to download" do
        allow(preview_asset_service).to receive(:can_preview_asset?) { true }
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.asset).to be_a FileAttachment::Asset
        expect(result.can_preview).to be_truthy
        expect(result.api_error).to be_falsey
      end

      it "returns a can_preview flag when the asset is unavailable" do
        allow(preview_asset_service).to receive(:can_preview_asset?) { false }
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.can_preview).to be_falsey
      end

      it "returns an api_error flag when Asset Manager is down" do
        allow(preview_asset_service).to receive(:can_preview_asset?).and_raise(GdsApi::BaseError)
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.api_error).to be_truthy
      end
    end

    context "when the asset is absent from Asset Manager" do
      let(:attachment_revision) do
        create :file_attachment_revision, file_attachment: file_attachment
      end

      before do
        allow(preview_asset_service).to receive(:upload_asset)
        edition.file_attachment_revisions << attachment_revision
      end

      it "uploads the asset" do
        expect(preview_asset_service).to receive(:upload_asset)
        FileAttachments::PreviewInteractor.call(params: params)
      end

      it "returns a can_preview flag" do
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.can_preview).to be_falsey
      end

      it "returns an api_error flag when Asset Manager is down" do
        allow(preview_asset_service).to receive(:upload_asset).and_raise(GdsApi::BaseError)
        result = FileAttachments::PreviewInteractor.call(params: params)
        expect(result.api_error).to be_truthy
      end
    end
  end
end
