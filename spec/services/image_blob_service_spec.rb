# frozen_string_literal: true

RSpec.describe ImageBlobService do
  let(:file) { fixture_file_upload("files/1000x1000.jpg") }
  let(:revision) { build(:revision) }
  let(:user) { build(:user) }
  let(:instance) { ImageBlobService.new(revision, user) }

  describe "#create_blob_revision" do
    it "creates a image blob revision" do
      expect(instance.create_blob_revision(file))
        .to be_a(Image::BlobRevision)
    end

    context "when the filename is used by an image for this revision" do
      let(:existing_image) { build(:image_revision, filename: "1000x1000.jpg") }
      let(:revision) { build(:revision, image_revisions: [existing_image]) }

      it "creates a unique filename" do
        blob_revision = instance.create_blob_revision(file)
        expect(blob_revision.filename).to eql("1000x1000-1.jpg")
      end
    end
  end
end
