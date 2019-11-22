# frozen_string_literal: true

RSpec.describe ImageBlobService do
  let(:user) { build(:user) }
  let(:temp_image) do
    ImageNormaliser::TempImage.new(fixture_file_upload("files/1000x1000.jpg"))
  end

  describe ".call" do
    it "creates a image blob revision" do
      expect(ImageBlobService.call(user: user, temp_image: temp_image, filename: "1000x1000.jpg"))
        .to be_a(Image::BlobRevision)
    end
  end
end
