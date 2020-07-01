RSpec.describe EditionUrlHelper do
  let(:edition) do
    build(:edition,
          base_path: "/foo",
          content_id: "d2547c42-8ed3-49f5-baeb-6112f98c2bf9")
  end

  describe "#public_url" do
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

  describe "#preview_url" do
    it "returns the URL with an auth bypass token" do
      expect(edition).to receive(:auth_bypass_token).and_return("secret")
      url = edition_preview_url(edition)
      expect(url).to eq("https://draft-origin.test.gov.uk/foo?token=secret")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = edition_preview_url(edition)
      expect(url).to be_nil
    end
  end
end
