# frozen_string_literal: true

RSpec.describe ExternalUrlHelper, type: :helper do
  let(:edition) do
    build(:edition,
          base_path: "/foo",
          content_id: "d2547c42-8ed3-49f5-baeb-6112f98c2bf9")
  end

  describe "#edition_public_url" do
    it "returns the URL" do
      url = edition_public_url(edition)
      expect(url).to eq("https://www.test.gov.uk/foo")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = edition_public_url(edition)
      expect(url).to be_nil
    end
  end

  describe "#edition_preview_url" do
    let(:preview_auth_bypass_service) do
      instance_double(PreviewAuthBypassService, preview_token: "secret")
    end

    before do
      allow(PreviewAuthBypassService).to receive(:new) { preview_auth_bypass_service }
    end

    it "returns the URL" do
      url = edition_preview_url(edition)
      expect(url).to eq("https://draft-origin.test.gov.uk/foo?token=secret")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = edition_preview_url(edition)
      expect(url).to be_nil
    end
  end

  describe "#draft_host_url" do
    it "returns the URL" do
      url = draft_host_url
      expect(url).to eq("https://draft-origin.test.gov.uk")
    end
  end
end
