# frozen_string_literal: true

RSpec.describe "Import tasks" do
  describe "import:whitehall" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:import_data) do
      {
        "id" => 1,
        "created_at" => Time.current,
        "updated_at" => Time.current,
        "slug" => "some-news-document",
        "content_id" => SecureRandom.uuid,
        "editions" => [
          {
            "id" => 1,
            "created_at" => Time.current,
            "updated_at" => Time.current,
            "title" => "Title",
            "summary" => "Summary",
            "change_note" => "First published",
            "state" => "draft",
            "translations" => [
              {
                "id" => 1,
                "locale" => "en",
                "title" => "Title",
                "summary" => "Summary",
                "body" => "Body",
              },
            ],
            "organisations" => [
              {
                "id" => 1,
                "content_id" => SecureRandom.uuid,
                "lead" => true,
                "lead_ordering" => 1,
              },
            ],
          },
        ],
      }
    end

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
  end
end
