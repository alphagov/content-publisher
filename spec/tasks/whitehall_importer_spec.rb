# frozen_string_literal: true

RSpec.describe Tasks::WhitehallImporter do
  include FixturesHelper

  let(:import_data) { whitehall_export_with_one_edition }

  it "can import JSON data from Whitehall" do
    importer = Tasks::WhitehallImporter.new(123, import_data)

    expect { importer.import }.to change { Document.count }.by(1)

    imported_edition = import_data["editions"][0]
    edition = Edition.last

    expect(edition.summary)
      .to eq(imported_edition["translations"][0]["summary"])

    expect(edition.number).to eql(1)
    expect(edition.status).to be_draft
    expect(edition.update_type).to eq("major")
  end

  it "adds users who have never logged into Content Publisher" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(User.last.uid).to eq "36d5154e-d3b7-4e3e-aad8-32a50fc9430e"
    expect(User.last.name).to eq "A Person"
    expect(User.last.email).to eq "a-publisher@department.gov.uk"
    expect(User.last.organisation_slug).to eq "a-government-department"
    expect(User.last.organisation_content_id).to eq "01892f23-b069-43f5-8404-d082f8dffcb9"
  end

  it "does not add users who have logged into Content Publisher" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    User.create!(uid: "36d5154e-d3b7-4e3e-aad8-32a50fc9430e")

    expect { importer.import }.not_to(change { User.count })
  end

  it "creates a user map" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expected_user_ids = {
      1 => User.last.id,
    }

    expect(importer.user_ids).to eq(expected_user_ids)
  end

  it "sets created_by_id as the original author" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Document.last.created_by_id).to eq(User.last.id)
  end

  it "sets import_from as Whitehall" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    document = Document.last
    expect(document.imported_from_whitehall?).to be true
  end

  it "sets the correct states when Whitehall document state is 'published'" do
    import_data["editions"][0]["state"] = "published"
    import_data["editions"][0]["revision_history"] << {
      "event" => "update",
      "state" => "published",
      "whodunnit" => 1,
    }
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.status).to be_published
    expect(Edition.last).to be_live
  end

  it "can set minor update type" do
    import_data["editions"][0]["minor_change"] = true
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.update_type).to eq("minor")
  end


  it "sets the correct states when Whitehall document is force published" do
    import_data["editions"][0]["state"] = "published"
    import_data["editions"][0]["force_published"] = true
    import_data["editions"][0]["revision_history"] << {
      "event" => "update",
      "state" => "published",
      "whodunnit" => 1,
    }
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.status).to be_published_but_needs_2i
    expect(Edition.last).to be_live
  end

  it "sets the correct states when Whitehall document state is 'rejected'" do
    import_data["editions"][0]["state"] = "rejected"
    import_data["editions"][0]["revision_history"] << {
      "event" => "update",
      "state" => "rejected",
      "whodunnit" => 1,
    }
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.status).to be_submitted_for_review
    expect(Edition.last).not_to be_live
  end

  it "sets the correct states when Whitehall document state is 'submitted'" do
    import_data["editions"][0]["state"] = "submitted"
    import_data["editions"][0]["revision_history"] << {
      "event" => "update",
      "state" => "submitted",
      "whodunnit" => 1,
    }
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.status).to be_submitted_for_review
    expect(Edition.last).not_to be_live
  end

  it "raises AbortImportError when edition has an unsupported state" do
    import_data["editions"][0]["state"] = "not_supported"
    importer = Tasks::WhitehallImporter.new(123, import_data)

    expect { importer.import }.to raise_error(Tasks::AbortImportError)
  end

  it "raises AbortImportError when revision history is missing for state" do
    import_data["editions"][0]["state"] = "published"
    importer = Tasks::WhitehallImporter.new(123, import_data)

    expect { importer.import }.to raise_error(Tasks::AbortImportError)
  end

  it "sets the created_at datetime of the document state" do
    import_data["editions"][0]["revision_history"][0].merge!("created_at" => 3.days.ago)

    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    imported_created_at = import_data["editions"][0]["revision_history"][0]["created_at"]

    expect(Edition.last.status.created_at).to be_within(1.second).of imported_created_at
  end

  it "raises AbortImportError when edition has an unsupported locale" do
    import_data["editions"][0]["translations"][0]["locale"] = "zz"
    importer = Tasks::WhitehallImporter.new(123, import_data)

    expect { importer.import }.to raise_error(Tasks::AbortImportError)
  end

  it "changes the ids of embedded contacts" do
    import_data["editions"][0]["translations"][0]["body"] = "[Contact:123]"
    content_id = SecureRandom.uuid
    import_data["editions"][0]["contacts"] = [{ "id" => 123, "content_id" => content_id }]
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    expect(Edition.last.contents["body"]).to eq("[Contact:#{content_id}]")
  end

  context "when importing organisation associations" do
    it "sets a primary_publishing_organisation" do
      importer = Tasks::WhitehallImporter.new(123, import_data)
      importer.import

      imported_organisation = import_data["editions"][0]["organisations"][0]
      edition = Edition.last

      expect(edition.primary_publishing_organisation_id).to eq(imported_organisation["content_id"])
    end

    it "rejects the import if there are no organisations" do
      import_data["editions"][0].delete("organisations")
      importer = Tasks::WhitehallImporter.new(123, import_data)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end

    it "rejects the import if there are no lead organisations" do
      import_data["editions"][0]["organisations"].shift
      importer = Tasks::WhitehallImporter.new(123, import_data)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end

    it "rejects the import if there is more than one lead organisation" do
      import_data["editions"][0]["organisations"].push(
        "id" => 3,
        "content_id" => SecureRandom.uuid,
        "lead" => true,
        "lead_ordering" => 2,
      )

      importer = Tasks::WhitehallImporter.new(123, import_data)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end

    it "sets other supporting organisations" do
      importer = Tasks::WhitehallImporter.new(123, import_data)
      importer.import

      imported_organisation = import_data["editions"][0]["organisations"][1]
      edition = Edition.last

      expect(edition.supporting_organisation_ids.first).to eq(imported_organisation["content_id"])
    end
  end

  it "sets role appointments" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    imported_role_appointment = import_data["editions"][0]["role_appointments"][0]
    edition = Edition.last

    expect(edition.tags["role_appointments"].first).to eq(imported_role_appointment["content_id"])
  end

  it "sets topical events" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    imported_topical_events = import_data["editions"][0]["topical_events"][0]
    edition = Edition.last

    expect(edition.tags["topical_events"].first).to eq(imported_topical_events["content_id"])
  end

  it "sets world locations" do
    importer = Tasks::WhitehallImporter.new(123, import_data)
    importer.import

    imported_world_locations = import_data["editions"][0]["world_locations"][0]
    edition = Edition.last

    expect(edition.tags["world_locations"].first).to eq(imported_world_locations["content_id"])
  end

  context "when an imported document has more than one edition" do
    let(:import_published_then_drafted_data) { whitehall_export_with_two_editions }

    it "only creates the latest edition" do
      importer = Tasks::WhitehallImporter.new(123, import_published_then_drafted_data)
      importer.import

      expect(Edition.last.status).to be_draft
      expect(Edition.last).not_to be_live
    end

    it "sets imported to true on revision" do
      importer = Tasks::WhitehallImporter.new(123, import_published_then_drafted_data)
      importer.import

      expect(Revision.last.imported).to be true
    end

    it "sets created_by_id on each edition as the original edition author" do
      importer = Tasks::WhitehallImporter.new(123, import_published_then_drafted_data)
      importer.import

      expect(Edition.second_to_last.created_by_id).to eq(User.second_to_last.id)
      expect(Edition.last.created_by_id).to eq(User.last.id)
    end

    it "sets last_edited_by_id on each edition as the most recent author" do
      importer = Tasks::WhitehallImporter.new(123, import_published_then_drafted_data)
      importer.import

      expect(Edition.second_to_last.last_edited_by_id).to eq(User.second_to_last.id)
      expect(Edition.last.last_edited_by_id).to eq(User.second_to_last.id)
    end

    it "raises AbortImportError when an edition has an unsupported document type" do
      import_published_then_drafted_data["editions"][0]["news_article_type"] = "unsupported_document"
      importer = Tasks::WhitehallImporter.new(123, import_published_then_drafted_data)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end
  end

  context "when importing a withdrawn document" do
    let(:import_data_for_withdrawn_edition) { whitehall_export_with_one_withdrawn_edition }

    it "sets the correct states when Whitehall document state is withdrawn" do
      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)
      importer.import

      expect(Status.count).to eq(2)
      expect(Status.first.state).to eq("published")
      expect(Edition.last.status).to be_withdrawn
      expect(Edition.last).not_to be_live
    end

    it "sets the correct states when Whitehall document state is withdrawn and was force_published" do
      import_data_for_withdrawn_edition["editions"][0]["force_published"] = true

      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)
      importer.import

      expect(Status.count).to eq(2)
      expect(Status.first.state).to eq("published_but_needs_2i")
      expect(Edition.last.status).to be_withdrawn
      expect(Edition.last).not_to be_live
    end

    it "sets the created_by_id of each status if more than one state needs to be recorded" do
      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)
      importer.import

      expect(Status.first.created_by_id).to eq(User.second_to_last.id)
      expect(Edition.last.status.created_by_id).to eq(User.last.id)
    end

    it "raises AbortImportError when revision history cannot be found for state" do
      import_data_for_withdrawn_edition["editions"][0]["revision_history"].delete_at(1)
      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end

    it "sets the created_at datetime of the initial and current document states" do
      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)
      importer.import

      import_revision_history = import_data_for_withdrawn_edition["editions"][0]["revision_history"]

      expect(Status.first.created_at).to eq(import_revision_history[1]["created_at"])
      expect(Edition.last.status.created_at).to eq(import_revision_history[2]["created_at"])
    end

    it "raises AbortImportError when document is withdrawn but has no unpublishing details" do
      import_data_for_withdrawn_edition["editions"][0]["unpublishing"] = nil
      importer = Tasks::WhitehallImporter.new(123, import_data_for_withdrawn_edition)

      expect { importer.import }.to raise_error(Tasks::AbortImportError)
    end
  end
end
