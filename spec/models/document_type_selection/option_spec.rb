RSpec.describe DocumentTypeSelection::Option do
  describe "#managed_elsewhere?" do
    it "returns true if the option is managed_elsewhere" do
      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
      }

      expect(described_class.new(option).managed_elsewhere?).to be true
    end
  end

  describe "#managed_elsewhere_url" do
    it "returns the path if a hostname is not provided" do
      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
        "path" => "/bar",
      }

      expect(described_class.new(option).managed_elsewhere_url).to eq("/bar")
    end

    it "returns the full url if the hostname is provided" do
      whitehall_host = Plek.external_url_for("whitehall-admin")

      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
        "hostname" => "whitehall-admin",
        "path" => "/bar",
      }

      expect(described_class.new(option).managed_elsewhere_url).to eq("#{whitehall_host}/bar")
    end
  end

  describe "#document_type_selection?" do
    it "returns true when the option is a document_type_selection" do
      option = {
        "id" => "foo",
        "type" => "document_type_selection",
      }

      expect(described_class.new(option).document_type_selection?).to be true
    end
  end

  describe "#document_type?" do
    it "returns true when the option is a document_type" do
      option = {
        "id" => "foo",
        "type" => "document_type",
      }

      expect(described_class.new(option).document_type?).to be true
    end
  end

  describe "#pre_release?" do
    it "returns true when the option is an existing document type and a pre-release feature" do
      pre_release_document_type = build(:document_type, :pre_release)

      allow(DocumentType)
        .to receive(:all)
        .and_return([pre_release_document_type])

      option = {
        "id" => pre_release_document_type.id,
        "type" => "document_type",
      }

      expect(described_class.new(option).pre_release?).to be true
    end

    it "returns false when the option is not a document type" do
      option = {
        "id" => "foo",
      }

      expect(described_class.new(option).pre_release?).to be false
    end
  end
end
