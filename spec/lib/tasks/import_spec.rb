# frozen_string_literal: true

RSpec.describe "Import tasks" do
  describe "import:whitehall" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

    before do
      Rake::Task["import:whitehall"].reenable
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: build(:whitehall_export_document).to_json)
    end

    it "creates a document" do
      expect { Rake::Task["import:whitehall"].invoke("123") }.to change { Document.count }.by(1)
    end
  end
end
