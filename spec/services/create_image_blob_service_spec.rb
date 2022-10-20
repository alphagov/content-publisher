RSpec.describe CreateImageBlobService do
  let(:user) { build(:user) }
  let(:temp_image) do
    ImageNormaliser::TempImage.new(fixture_file_upload("1000x1000.jpg"))
  end

  describe ".call" do
    it "creates a image blob revision" do
      expect(described_class.call(user:, temp_image:, filename: "1000x1000.jpg"))
        .to be_a(Image::BlobRevision)
    end
  end
end
