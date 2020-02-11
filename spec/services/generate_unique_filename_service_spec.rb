RSpec.describe GenerateUniqueFilenameService do
  let(:existing_filenames) { ["file1.jpg"] }

  describe "#call" do
    it "parameterises the base filename" do
      name = described_class.call(filename: "File $ name.jpg",
                                                existing_filenames: existing_filenames)
      expect(name).to eq "file-name.jpg"
    end

    it "copes if the file has no extension" do
      name = described_class.call(filename: "file",
                                               existing_filenames: existing_filenames)
      expect(name).to eq "file"
    end

    it "truncates lengthy base filenames" do
      stub_const "GenerateUniqueFilenameService::MAX_LENGTH", 3
      name = described_class.call(filename: "mylongname.jpg",
                                                existing_filenames: existing_filenames)
      expect(name).to eq "myl.jpg"
    end

    it "ensures the filename is unique for a list of filenames" do
      existing_filenames << "file.jpg"
      name = described_class.call(filename: "file.jpg",
                                               existing_filenames: existing_filenames)
      expect(name).to eq "file-1.jpg"
    end
  end
end
