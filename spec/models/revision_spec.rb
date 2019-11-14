# frozen_string_literal: true

RSpec.describe Revision do
  include ActiveSupport::Testing::TimeHelpers

  describe ".create_initial" do
    let(:document) { build(:document) }

    it "creates an empty revision for the document" do
      revision = Revision.create_initial(
        document: document,
        document_type_id: document.document_type_id,
      )

      expect(revision).to be_a(Revision)
      expect(revision).not_to be_new_record
      expect(revision.document).to eq(document)
      expect(revision.title).to be_nil
    end

    it "sets default change note and update type" do
      revision = Revision.create_initial(
        document: document,
        document_type_id: document.document_type_id,
      )

      expect(revision.change_note).to eq("First published.")
      expect(revision.update_type).to eq("major")
    end

    it "can associate records with a user" do
      user = build(:user)
      revision = Revision.create_initial(
        document: document,
        document_type_id: document.document_type_id,
        user: user,
      )

      expect(revision.created_by).to eq(user)
      expect(revision.content_revision.created_by).to eq(user)
      expect(revision.metadata_revision.created_by).to eq(user)
      expect(revision.tags_revision.created_by).to eq(user)
    end

    it "can set tags" do
      tags = { "type" => %w[value1 value2] }
      revision = Revision.create_initial(
        document: document,
        document_type_id: document.document_type_id,
        user: nil,
        tags: tags,
      )

      expect(revision.tags).to eq(tags)
    end
  end
end
