# frozen_string_literal: true

RSpec.describe WhitehallImporter::Import do
  include FixturesHelper

  describe ".call" do
    let(:import_data) { whitehall_export_with_one_edition }

    it "creates a document" do
      expect { described_class.call(import_data) }.to change { Document.count }.by(1)
    end

    it "aborts if a document already exists" do
      create(:document, content_id: import_data["content_id"])
      expect { described_class.call(import_data) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "adds users who have never logged into Content Publisher" do
      described_class.call(import_data)

      expect(User.last.uid).to eq "36d5154e-d3b7-4e3e-aad8-32a50fc9430e"
      expect(User.last.name).to eq "A Person"
      expect(User.last.email).to eq "a-publisher@department.gov.uk"
      expect(User.last.organisation_slug).to eq "a-government-department"
      expect(User.last.organisation_content_id).to eq "01892f23-b069-43f5-8404-d082f8dffcb9"
    end

    it "does not add users who have logged into Content Publisher" do
      User.create!(uid: "36d5154e-d3b7-4e3e-aad8-32a50fc9430e")

      expect { described_class.call(import_data) }.not_to(change { User.count })
    end

    it "sets created_by_id as the original author" do
      described_class.call(import_data)

      expect(Document.last.created_by_id).to eq(User.last.id)
    end

    it "sets import_from as Whitehall" do
      described_class.call(import_data)

      expect(Document.last.imported_from_whitehall?).to be true
    end
  end
end
