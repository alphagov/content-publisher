# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  include FixturesHelper

  let(:import_data) { whitehall_export_with_one_edition }

  it "can import JSON data from Whitehall" do
    importer = WhitehallImporter.new(import_data)

    expect { importer.import }.to change { Document.count }.by(1)

    imported_edition = import_data["editions"][0]
    edition = Edition.last

    expect(edition.summary)
      .to eq(imported_edition["translations"][0]["summary"])

    expect(edition.base_path).to eq(imported_edition["translations"][0]["base_path"])

    expect(edition.number).to eql(1)
    expect(edition.status).to be_draft
    expect(edition.update_type).to eq("major")
  end

  it "adds users who have never logged into Content Publisher" do
    importer = WhitehallImporter.new(import_data)
    importer.import

    expect(User.last.uid).to eq "36d5154e-d3b7-4e3e-aad8-32a50fc9430e"
    expect(User.last.name).to eq "A Person"
    expect(User.last.email).to eq "a-publisher@department.gov.uk"
    expect(User.last.organisation_slug).to eq "a-government-department"
    expect(User.last.organisation_content_id).to eq "01892f23-b069-43f5-8404-d082f8dffcb9"
  end

  it "does not add users who have logged into Content Publisher" do
    importer = WhitehallImporter.new(import_data)
    User.create!(uid: "36d5154e-d3b7-4e3e-aad8-32a50fc9430e")

    expect { importer.import }.not_to(change { User.count })
  end

  it "creates a user map" do
    importer = WhitehallImporter.new(import_data)
    importer.import

    expected_user_ids = {
      1 => User.last.id,
    }

    expect(importer.user_ids).to eq(expected_user_ids)
  end

  it "sets created_by_id as the original author" do
    importer = WhitehallImporter.new(import_data)
    importer.import

    expect(Document.last.created_by_id).to eq(User.last.id)
  end

  it "sets import_from as Whitehall" do
    importer = WhitehallImporter.new(import_data)
    importer.import

    document = Document.last
    expect(document.imported_from_whitehall?).to be true
  end

  it "raises AbortImportError when edition has an unsupported locale" do
    import_data["editions"][0]["translations"][0]["locale"] = "zz"
    importer = WhitehallImporter.new(import_data)

    expect { importer.import }.to raise_error(WhitehallImporter::AbortImportError)
  end

  context "when an imported document has more than one edition" do
    let(:import_published_then_drafted_data) { whitehall_export_with_two_editions }

    it "only creates the latest edition" do
      importer = WhitehallImporter.new(import_published_then_drafted_data)
      importer.import

      expect(Edition.last.status).to be_draft
      expect(Edition.last).not_to be_live
    end

    it "sets created_by_id on each edition as the original edition author" do
      importer = WhitehallImporter.new(import_published_then_drafted_data)
      importer.import

      expect(Edition.second_to_last.created_by_id).to eq(User.second_to_last.id)
      expect(Edition.last.created_by_id).to eq(User.last.id)
    end

    it "sets last_edited_by_id on each edition as the most recent author" do
      importer = WhitehallImporter.new(import_published_then_drafted_data)
      importer.import

      expect(Edition.second_to_last.last_edited_by_id).to eq(User.second_to_last.id)
      expect(Edition.last.last_edited_by_id).to eq(User.second_to_last.id)
    end
  end
end
