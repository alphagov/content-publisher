RSpec.describe WhitehallImporter::CreateImageRevision do
  describe "#call" do
    let(:whitehall_image) { build(:whitehall_export_image) }
    let(:document_import) { build(:whitehall_migration_document_import) }

    context "Valid image is provided" do
      it "creates an Image::Revision" do
        image_revision = nil
        expect { image_revision = WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image) }
          .to change { Image::Revision.count }.by(1)
        expect(image_revision.caption).to eq(whitehall_image["caption"])
        expect(image_revision.alt_text).to eq(whitehall_image["alt_text"])
        expect(image_revision.filename).to eq("valid-image.jpg")
      end

      it "creates a WhitehallMigration::AssetImport for each image variant" do
        revision = WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image)

        expect(document_import.assets.size).to eq(2)
        expect(document_import.assets.map(&:attributes).map(&:with_indifferent_access))
          .to contain_exactly(
            a_hash_including(variant: nil,
                            image_revision_id: revision.id,
                            original_asset_url: whitehall_image["url"]),
            a_hash_including(variant: "s960",
                            image_revision_id: revision.id,
                            original_asset_url: whitehall_image["variants"]["s960"]),
          )
      end
    end

    context "Image is not available" do
      let(:image_url) { "https://assets.publishing.service.gov.uk/government/uploads/404ing-image.jpg" }
      let(:whitehall_image) do
        whitehall_image = build(:whitehall_export_image, url: image_url)
        stub_request(:get, image_url).to_return(status: 404)
        whitehall_image
      end

      it "raises a WhitehallImporter::AbortImportError" do
        expect { WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          "Image does not exist: #{image_url}",
        )
      end
    end

    context "Image is wrong type" do
      let(:whitehall_image) do
        build(:whitehall_export_image, filename: "vector.svg", fixture_file: "coffee.svg")
      end

      it "passes through ImageUploadChecker and raise a WhitehallImporter::AbortImportError" do
        expect(Requirements::ImageUploadChecker).to receive(:new).and_call_original
        expect { WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          I18n.t!("requirements.image_upload.unsupported_type.form_message"),
        )
      end
    end

    context "Image is too small" do
      let(:whitehall_image) do
        build(:whitehall_export_image, fixture_file: "100x100.jpg")
      end

      it "passes through ImageNormaliser and raise a WhitehallImporter::AbortImportError" do
        expect(ImageNormaliser).to receive(:new).and_call_original
        expect { WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image) }.to raise_error(
          WhitehallImporter::AbortImportError,
          I18n.t!("requirements.image_upload.too_small.form_message", width: 960, height: 640),
        )
      end
    end

    context "Original image filename is URL-unfriendly" do
      let(:whitehall_image) do
        build(:whitehall_export_image, filename: "Whitehall--Asset_-image.jpg")
      end

      it "renames the file to something URL-friendly" do
        WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image)
        expect(Image::BlobRevision.last.filename).to eq("whitehall-asset_-image.jpg")
      end
    end

    context "Image has exif data" do
      let(:whitehall_image) do
        build(:whitehall_export_image, fixture_file: "960x640-rotated.jpg")
      end

      it "strips the exif data from the image" do
        revision = WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image, ["valid-image.jpg"])

        image = MiniMagick::Image.open(revision.blob)
        expect(image.exif).to be_empty
      end
    end

    it "renames the file if duplicate filenames are passed" do
      WhitehallImporter::CreateImageRevision.call(document_import, whitehall_image, ["valid-image.jpg"])
      expect(Image::BlobRevision.last.filename).to eq("valid-image-1.jpg")
    end
  end
end
