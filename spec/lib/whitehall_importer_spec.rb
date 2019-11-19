# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  include FixturesHelper

  describe ".import" do
    before { allow(WhitehallImporter::Import).to receive(:call) }

    let(:import_data) { whitehall_export_with_one_edition }

    it "creates a WhitehallImport" do
      expect { WhitehallImporter.import(import_data) }
        .to change { WhitehallImport.count }
        .by(1)
    end

    it "imports a document" do
      expect(WhitehallImporter::Import).to receive(:call)
      WhitehallImporter.import(import_data)
    end

    it "stores the payload" do
      record = WhitehallImporter.import(import_data)
      expect(record.payload).to eq(import_data)
    end

    context "when the import is successful" do
      it "marks the import as completed" do
        record = WhitehallImporter.import(import_data)
        expect(record).to be_completed
      end
    end

    context "when the import fails" do
      before do
        allow(WhitehallImporter::Import).to receive(:call).and_raise(message)
      end

      let(:message) { "Import failed" }

      it "marks the import as failed and logs the error" do
        record = WhitehallImporter.import(import_data)
        expect(record).to be_failed
        expect(record.error_log).to eq(message)
      end
    end
  end
end
