# frozen_string_literal: true

RSpec.describe WhitehallImporter::Import do
  describe ".call" do
    it "creates a document" do
      expect { described_class.call(build(:whitehall_export_document)) }
        .to change { Document.count }.by(1)
    end

    it "aborts if a document already exists" do
      content_id = create(:document).content_id
      import_data = build(:whitehall_export_document, content_id: content_id)
      expect { described_class.call(import_data) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets the document as being imported from Whitehall" do
      document = described_class.call(build(:whitehall_export_document))

      expect(document).to be_imported_from_whitehall
    end

    it "creates users who have never logged into Content Publisher" do
      user = build(:whitehall_export_user)
      import_data = build(:whitehall_export_document, users: [user])

      described_class.call(import_data)
      expect(User.last.attributes).to match hash_including(
        "uid" => user["uid"],
        "name" => user["name"],
        "email" => user["email"],
        "organisation_slug" => user["organisation_slug"],
        "organisation_content_id" => user["organisation_content_id"],
      )
    end

    it "does not add users who have logged into Content Publisher" do
      user = build(:whitehall_export_user)
      User.create!(uid: user["uid"])
      import_data = build(:whitehall_export_document, users: [user])

      expect { described_class.call(import_data) }.not_to(change { User.count })
    end

    it "sets created_by_id as the original author" do
      whitehall_user = build(:whitehall_export_user)
      user = User.create!(uid: whitehall_user["uid"])
      edition = build(
        :whitehall_export_edition,
        revision_history: [
          { "event" => "create", "state" => "draft", "whodunnit" => whitehall_user["id"] },
        ],
      )

      import_data = build(:whitehall_export_document,
                          editions: [edition],
                          users: [whitehall_user])
      document = described_class.call(import_data)

      expect(document.created_by).to eq(user)
    end
  end
end
