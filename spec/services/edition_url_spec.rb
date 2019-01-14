# frozen_string_literal: true

RSpec.describe EditionUrl do
  let(:edition) do
    build(:edition,
          base_path: "/foo",
          content_id: "d2547c42-8ed3-49f5-baeb-6112f98c2bf9")
  end

  describe "#public_url" do
    it "returns the URL" do
      url = EditionUrl.new(edition).public_url
      expect(url).to eq("https://www.test.gov.uk/foo")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = EditionUrl.new(edition).public_url
      expect(url).to be_nil
    end
  end

  describe "#preview_url" do
    it "returns the URL" do
      url = EditionUrl.new(edition).preview_url
      expect(url).to eq("https://draft-origin.test.gov.uk/foo")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = EditionUrl.new(edition).preview_url
      expect(url).to be_nil
    end
  end

  describe "#secret_preview_url" do
    it "returns the URL" do
      url = EditionUrl.new(edition).secret_preview_url
      expect(url).to eq("https://draft-origin.test.gov.uk/foo?token=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMzMxMzEzMS0zMzY1LTQ4MzgtYjk2My0zNDM3MzYzNTMxNjYifQ.fFE5ctaewPYJap8hmsRyJ87L6a8Co8t9bbD0wpVYSgs")
    end

    it "returns nil without a base_path" do
      edition = build(:edition, base_path: nil)
      url = EditionUrl.new(edition).secret_preview_url
      expect(url).to be_nil
    end
  end
end
