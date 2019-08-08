# frozen_string_literal: true

RSpec.describe ImageBlobService do
  let(:revision) { build(:revision) }
  let(:user) { build(:user) }
  let(:instance) { ImageBlobService.new(revision, user) }

  let(:temp_image) do
    ImageNormaliser::TempImage.new(fixture_file_upload("files/1000x1000.jpg"))
  end

  describe "#call" do
    it "creates a image blob revision" do
      expect(ImageBlobService.new(revision, user, temp_image).call)
        .to be_a(Image::BlobRevision)
    end

    context "when the filename is used by an image for this revision" do
      let(:existing_image) { build(:image_revision, filename: "1000x1000.jpg") }
      let(:revision) { build(:revision, image_revisions: [existing_image]) }

      it "creates a unique filename" do
        blob_revision = ImageBlobService.new(revision, user, temp_image).call
        expect(blob_revision.filename).to eql("1000x1000-1.jpg")
      end
    end
  end
end
