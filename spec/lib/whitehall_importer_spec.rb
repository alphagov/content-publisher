# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  include ActiveJob::TestHelper
  describe ".create_migration" do
    context "with organisation and type specified" do
      let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
      let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
      let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

      before do
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=1&type=news_article")
          .to_return(status: 200, body: whitehall_export_page_1.to_json)
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=2&type=news_article")
          .to_return(status: 200, body: whitehall_export_page_2.to_json)
      end

      it "creates a WhitehallMigration" do
        freeze_time do
          expect { WhitehallImporter.create_migration("123", "news_article") }.to change { WhitehallMigration.count }.by(1)
          expect(WhitehallMigration.last.organisation_content_id).to eq("123")
          expect(WhitehallMigration.last.document_type).to eq("news_article")
          expect(WhitehallMigration.last.document_subtypes).to eq([])
          expect(WhitehallMigration.last.created_at).to eq(Time.current)
        end
      end

      it "creates a pending WhitehallMigration::DocumentImport for each listed item" do
        expect { WhitehallImporter.create_migration("123", "news_article") }.to change { WhitehallMigration::DocumentImport.pending.count }.by(110)
      end

      it "queues a job for each listed document" do
        WhitehallImporter.create_migration("123", "news_article")
        expect(WhitehallDocumentImportJob).to have_been_enqueued.exactly(110).times
      end
    end

    context "with organisation, type and subtype specified" do
      let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
      let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
      let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

      before do
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=1&type=news_article&subtypes[]=news_story&subtypes[]=press_release")
          .to_return(status: 200, body: whitehall_export_page_1.to_json)
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=2&type=news_article&subtypes[]=news_story&subtypes[]=press_release")
          .to_return(status: 200, body: whitehall_export_page_2.to_json)
      end

      it "creates a WhitehallMigration" do
        freeze_time do
          expect { WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story)) }.to change { WhitehallMigration.count }.by(1)
          expect(WhitehallMigration.last.organisation_content_id).to eq("123")
          expect(WhitehallMigration.last.document_type).to eq("news_article")
          expect(WhitehallMigration.last.document_subtypes).to eq(%w(press_release news_story))
          expect(WhitehallMigration.last.created_at).to eq(Time.current)
        end
      end

      it "creates a pending WhitehallMigration::DocumentImport for each listed item" do
        expect { WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story)) }.to change { WhitehallMigration::DocumentImport.pending.count }.by(110)
      end

      it "queues a job for each listed document" do
        WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story))
        expect(WhitehallDocumentImportJob).to have_been_enqueued.exactly(110).times
      end
    end
  end
end
