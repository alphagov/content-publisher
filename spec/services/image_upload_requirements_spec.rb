# frozen_string_literal: true

RSpec.describe ImageUploadRequirements do
  describe "#errors" do
    it "returns an empty array when a valid image is uploaded" do
      uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      errors = ImageUploadRequirements.new(uploaded_file).errors
      expect(errors).to be_empty
    end

    it "returns an error when no image is specified" do
      errors = ImageUploadRequirements.new(nil).errors
      error = I18n.t("document_images.index.flashes.upload_requirements.no_file_selected")
      expect(errors).to eq([error])
    end


    it "returns an error when an incorrect file type is provided" do
      uploaded_file = fixture_file_upload("files/text-file.txt", "text/plain")
      errors = ImageUploadRequirements.new(uploaded_file).errors

      error = I18n.t("document_images.index.flashes.upload_requirements.invalid_format")
      expect(errors).to eq([error])
    end

    it "has an error when a file bigger than the max size is provided" do
      uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      allow(uploaded_file).to receive(:size).and_return(30.megabytes)
      errors = ImageUploadRequirements.new(uploaded_file).errors

      error = I18n.t("document_images.index.flashes.upload_requirements.max_size",
                     max_size: "20 MB")

      expect(errors).to eq([error])
    end

    it "has an error when a file smaller than the minimum dimensions is provided" do
      uploaded_file = fixture_file_upload("files/100x100.jpg", "image/jpeg")
      errors = ImageUploadRequirements.new(uploaded_file).errors

      error = I18n.t("document_images.index.flashes.upload_requirements.min_dimensions",
                     width: Image::WIDTH,
                     height: Image::HEIGHT)

      expect(errors).to eq([error])
    end
  end
end
