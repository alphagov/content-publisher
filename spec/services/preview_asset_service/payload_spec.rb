RSpec.describe PreviewAssetService::Payload do
  describe "#for_update" do
    it "returns a payload hash" do
      edition = build :edition
      payload = described_class.new(edition).for_update

      expect(payload).to match(
        draft: true,
        auth_bypass_ids: [edition.auth_bypass_id],
      )
    end

    context "when the edition is access limited" do
      it "returns a payload with the permitted org ids" do
        edition = build :edition, :access_limited
        allow(edition).to receive(:access_limit_organisation_ids).and_return("ids")
        payload = described_class.new(edition).for_update
        expect(payload[:access_limited_organisation_ids]).to eq "ids"
      end
    end
  end

  describe "#for_upload" do
    let(:asset) do
      double(bytes: "bytes", content_type: "image/png") # rubocop:disable RSpec/VerifiedDoubles
    end

    it "returns a payload hash" do
      edition = build :edition
      payload = described_class.new(edition).for_upload(asset)

      expect(payload).to match(
        content_type: "image/png",
        draft: true,
        auth_bypass_ids: [edition.auth_bypass_id],
        file: instance_of(PreviewAssetService::UploadedFile),
      )
    end

    context "when the edition is access limited" do
      it "returns a payload with the permitted org ids" do
        edition = build :edition, :access_limited
        allow(edition).to receive(:access_limit_organisation_ids).and_return("ids")
        payload = described_class.new(edition).for_upload(asset)
        expect(payload[:access_limited_organisation_ids]).to eq "ids"
      end
    end
  end
end
