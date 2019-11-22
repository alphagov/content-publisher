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

    context "Image is wrong type" do
      let(:whitehall_image) do
        build(:whitehall_export_image, filename: "vector.svg", fixture_file: "coffee.svg")
      end

      it "should pass through ImageUploadChecker and raise a WhitehallImporter::AbortImportError" do
        expect(Requirements::ImageUploadChecker).to receive(:new).and_call_original
        expect { described_class.call(whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          I18n.t!("requirements.image_upload.unsupported_type.form_message"),
        )
      end
    end

    context "Image is too small" do
      let(:whitehall_image) do
        build(:whitehall_export_image, fixture_file: "100x100.jpg")
      end

      it "should pass through ImageNormaliser and raise a WhitehallImporter::AbortImportError" do
        expect(ImageNormaliser).to receive(:new).and_call_original
        expect { described_class.call(whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          I18n.t!("requirements.image_upload.too_small.form_message", width: 960, height: 640),
        )
      end
    end

    context "Original image filename is URL-unfriendly" do
      let(:whitehall_image) do
        build(:whitehall_export_image, filename: "Whitehall--Asset_-image.jpg")
      end

      it "should rename the file to something URL-friendly" do
        described_class.call(whitehall_image)
        expect(Image::BlobRevision.last.filename).to eq("whitehall-asset_-image.jpg")
      end
    end

    it "should rename the file if duplicate filenames are passed" do
      described_class.call(whitehall_image, ["valid-image.jpg"])
      expect(Image::BlobRevision.last.filename).to eq("valid-image-1.jpg")
    end
  end
end
