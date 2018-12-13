# frozen_string_literal: true

RSpec.describe ImageFilenameService do
  describe "#call" do
    it "parameterises the base filename" do
      revision = build :revision
      name = ImageFilenameService.new(revision).call("File $ name.jpg")
      expect(name).to eq "file-name.jpg"
    end

    it "copes if the file has no extension" do
      revision = build :revision
      name = ImageFilenameService.new(revision).call("file")
      expect(name).to eq "file"
    end

    it "truncates lengthy base filenames" do
      stub_const "ImageFilenameService::MAX_LENGTH", 3
      revision = build :revision
      name = ImageFilenameService.new(revision).call("mylongname.jpg")
      expect(name).to eq "myl.jpg"
    end

    it "ensures the filename is unique for the revision" do
      revision = create(:revision)
      revision.image_revisions << create(:image_revision, filename: "name.jpg")
      revision.image_revisions << create(:image_revision, filename: "name-1.jpg")
      create(:image_revision, filename: "name-2.jpg")
      name = ImageFilenameService.new(revision).call("name.jpg")
      expect(name).to eq "name-2.jpg"
    end
  end
end
