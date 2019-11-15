# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateImageRevision do
  describe "#call" do
    let(:whitehall_image) { build(:whitehall_export_image) }

    it "should create an Image::Revision when a valid image is provided" do
      image_revision = nil
      expect { image_revision = described_class.call(whitehall_image) }
        .to change { Image::Revision.count }.by(1)
      expect(image_revision.caption).to eq(whitehall_image["caption"])
      expect(image_revision.alt_text).to eq(whitehall_image["alt_text"])
      expect(image_revision.filename).to eq("valid-image.jpg")
    end

    context "Image is not available" do
      let(:image_url) { "https://assets.publishing.service.gov.uk/government/uploads/404ing-image.jpg" }
      let(:whitehall_image) do
        whitehall_image = build(:whitehall_export_image, url: image_url)
        stub_request(:get, image_url).to_return(status: 404)
        whitehall_image
      end

      it "should raise a WhitehallImporter::AbortImportError" do
        expect { described_class.call(whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          "Image does not exist: #{image_url}",
        )
      end
    end
  end
end
