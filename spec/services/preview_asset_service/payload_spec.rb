# frozen_string_literal: true

RSpec.describe PreviewAssetService::Payload do
  let(:auth_bypass) do
    instance_double PreviewAuthBypassService, auth_bypass_id: "bypass-id"
  end

  before do
    allow(PreviewAuthBypassService).to receive(:new) { auth_bypass }
  end

  describe "#for_update" do
    it "returns a payload hash" do
      edition = build :edition
      payload = PreviewAssetService::Payload.new(edition).for_update

      expect(payload).to match(
        draft: true,
        auth_bypass_ids: %w[bypass-id],
      )
    end

    context "when the edition is access limited" do
      it "returns a payload with the permitted org ids" do
        edition = build :edition, :access_limited
        allow(edition).to receive(:access_limit_organisation_ids) { "ids" }
        payload = PreviewAssetService::Payload.new(edition).for_update
        expect(payload[:access_limited_organisation_ids]).to eq "ids"
      end
    end
  end

  describe "#for_upload" do
    let(:asset) { double(:asset, bytes: "bytes") }

    it "returns a payload hash" do
      edition = build :edition
      payload = PreviewAssetService::Payload.new(edition).for_upload(asset)

      expect(payload).to match(
        draft: true,
        auth_bypass_ids: %w[bypass-id],
        file: instance_of(PreviewAssetService::UploadedFile),
      )
    end

    context "when the edition is access limited" do
      it "returns a payload with the permitted org ids" do
        edition = build :edition, :access_limited
        allow(edition).to receive(:access_limit_organisation_ids) { "ids" }
        payload = PreviewAssetService::Payload.new(edition).for_upload(asset)
        expect(payload[:access_limited_organisation_ids]).to eq "ids"
      end
    end
  end
end
