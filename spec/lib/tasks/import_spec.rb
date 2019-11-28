# frozen_string_literal: true

RSpec.describe "Import tasks" do
  describe "import:whitehall" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

    before do
      allow($stdout).to receive(:puts)
      Rake::Task["import:whitehall"].reenable
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: build(:whitehall_export_document).to_json)
    end

    it "creates a document" do
      expect { Rake::Task["import:whitehall"].invoke("123") }.to change { Document.count }.by(1)
    end

    it "aborts if the import fails" do
      expect(WhitehallImporter::Import).to receive(:call).and_raise("Error importing")

      expect($stdout).to receive(:puts).with("Import failed")
      expect($stdout).to receive(:puts).with("Error: Error importing")
      expect { Rake::Task["import:whitehall"].invoke("123") }
        .to raise_error(SystemExit)
    end
  end
end
