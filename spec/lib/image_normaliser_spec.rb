# frozen_string_literal: true

RSpec.describe ImageNormaliser do
  describe "#normalise" do
    it "returns a temp image when valid" do
      file = fixture_file_upload("files/960x640.jpg")
      expect(ImageNormaliser.new(file).normalise).to be_a(ImageNormaliser::TempImage)
    end

    it "returns nil when the image is too small" do
      file = fixture_file_upload("files/100x100.jpg")
      expect(ImageNormaliser.new(file).normalise).to be_nil
    end

    it "returns nil when the image is animated" do
      file = fixture_file_upload("files/animated-gif.gif")
      expect(ImageNormaliser.new(file).normalise).to be_nil
    end
  end

  describe "#issues" do
    it "returns no issues when there are none" do
      file = fixture_file_upload("files/960x640.jpg")
      normaliser = ImageNormaliser.new(file)

      normaliser.normalise
      expect(normaliser.issues).to be_empty
    end

    it "returns an issue when the image too small" do
      file = fixture_file_upload("files/100x100.jpg")
      normaliser = ImageNormaliser.new(file)

      normaliser.normalise
      expect(normaliser.issues).to have_issue(:image_upload,
                                              :too_small,
                                              width: Image::WIDTH,
                                              height: Image::HEIGHT)
    end

    it "returns an issue when the image is animated" do
      file = fixture_file_upload("files/animated-gif.gif")
      normaliser = ImageNormaliser.new(file)

      normaliser.normalise
      expect(normaliser.issues).to have_issue(:image_upload, :animated_image)
    end
  end
end
