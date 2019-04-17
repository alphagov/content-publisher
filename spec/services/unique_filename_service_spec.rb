# frozen_string_literal: true

RSpec.describe UniqueFilenameService do
  let(:existing_filenames) { ["file1.jpg"] }

  describe "#call" do
    it "parameterises the base filename" do
      name = UniqueFilenameService.new(existing_filenames).call("File $ name.jpg")
      expect(name).to eq "file-name.jpg"
    end

    it "copes if the file has no extension" do
      name = UniqueFilenameService.new(existing_filenames).call("file")
      expect(name).to eq "file"
    end

    it "truncates lengthy base filenames" do
      stub_const "UniqueFilenameService::MAX_LENGTH", 3
      name = UniqueFilenameService.new(existing_filenames).call("mylongname.jpg")
      expect(name).to eq "myl.jpg"
    end

    it "ensures the filename is unique for a list of filenames" do
      existing_filenames << "file.jpg"
      name = UniqueFilenameService.new(existing_filenames).call("file.jpg")
      expect(name).to eq "file-1.jpg"
    end
  end
end
