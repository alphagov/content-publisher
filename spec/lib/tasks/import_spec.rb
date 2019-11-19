# frozen_string_literal: true

RSpec.describe "Import tasks" do
  include FixturesHelper

  describe "import:whitehall" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:import_data) { whitehall_export_with_one_edition }

    before do
      Rake::Task["import:whitehall"].reenable
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123").to_return(status: 200, body: import_data.to_json)
    end

    it "logs raw JSON from Whitehall" do
      expect { Rake::Task["import:whitehall"].invoke("123") }.to(change { WhitehallImport.count }.by(1))
      expect(WhitehallImport.last.payload).to eq(JSON.parse(import_data.to_json))
    end

    it "sets state to completed for valid payload" do
      Rake::Task["import:whitehall"].invoke("123")
      expect(WhitehallImport.last.state).to eq("completed")
    end

    it "logs an error but does not fail if the import is aborted" do
      allow_any_instance_of(WhitehallImporter).to receive(:import).and_raise(WhitehallImporter::AbortImportError)

      expect { Rake::Task["import:whitehall"].invoke("123") }.to_not raise_error
      expect(WhitehallImport.last.state).to eq("failed")
    end

    it "creates a document" do
      expect { Rake::Task["import:whitehall"].invoke("123") }.to change { Document.count }.by(1)
      expect(Document.last.content_id).to eq(import_data["content_id"])
    end

    it "creates the users associated with the document" do
      expect { Rake::Task["import:whitehall"].invoke("123") }.to change { User.count }.by(1)
      expect(User.last.name).to eq(import_data["users"].first["name"])
    end
  end
end
