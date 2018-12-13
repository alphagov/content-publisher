# frozen_string_literal: true

RSpec.describe ImageFilenameService do
  describe "#call" do
    it "parameterises the base filename" do
      document = build :document
      name = ImageFilenameService.new(document).call("File $ name.jpg", "image/jpeg")
      expect(name).to eq "file-name.jpg"
    end

    it "enforces an extension for the filename" do
      document = build :document
      name = ImageFilenameService.new(document).call("file.jpg", "image/png")
      expect(name).to eq "file.png"
    end

    it "ensures the filename is unique" do
      document = create(:document)
      create(:image, document: document, filename: "name.jpg")
      create(:image, document: document, filename: "name-1.jpg")
      create(:image, filename: "name-2.jpg")
      name = ImageFilenameService.new(document).call("name.jpg", "image/jpeg")
      expect(name).to eq "name-2.jpg"
    end
  end
end
