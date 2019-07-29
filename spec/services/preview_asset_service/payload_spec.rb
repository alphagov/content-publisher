# frozen_string_literal: true

RSpec.describe PreviewAssetService::Payload do
  let(:edition) { build :edition }

  let(:auth_bypass) do
    instance_double PreviewAuthBypassService, auth_bypass_id: "bypass-id"
  end

  before do
    allow(PreviewAuthBypassService).to receive(:new) { auth_bypass }
  end

  describe "#for_update" do
    it "returns a payload hash" do
      payload = PreviewAssetService::Payload.new(edition).for_update

      expect(payload).to match a_hash_including(
        draft: true,
        auth_bypass_ids: %w[bypass-id],
      )
    end
  end

  describe "#for_upload" do
    it "returns a payload hash" do
      asset = double(:asset, bytes: "bytes")
      payload = PreviewAssetService::Payload.new(edition).for_upload(asset)

      expect(payload).to match a_hash_including(
        draft: true,
        auth_bypass_ids: %w[bypass-id],
        file: instance_of(PreviewAssetService::UploadedFile),
      )
    end
  end
end
