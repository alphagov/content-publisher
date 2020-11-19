RSpec.describe Healthcheck::ActiveStorage do
  describe "#status" do
    it "returns OK when connected to the storage service" do
      expect(described_class.new.status).to eq GovukHealthcheck::OK
    end

    it "returns CRITICAL when the storage connection fails" do
      allow(ActiveStorage::Blob.service).to receive(:exist?)
        .and_raise("connection failed")

      expect(described_class.new.status).to eq GovukHealthcheck::CRITICAL
    end
  end
end
