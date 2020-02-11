RSpec.describe CreateDocumentService do
  describe ".call" do
    let(:document_type) { build(:document_type) }

    it "creates a document" do
      expect { CreateDocumentService.call(document_type_id: document_type.id) }
        .to change(Document, :count).by(1)
    end

    it "runs inside a transaction so failures are rolled back" do
      expect(Document).to receive(:transaction)
      CreateDocumentService.call(document_type_id: document_type.id)
    end

    it "sets the document to have a draft current edition for the appropriate document type" do
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition).to be_draft
      expect(document.current_edition.document_type).to eq(document_type)
    end

    it "sets the numbers of the first edition and first revision accordingly" do
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition.number).to be(1)
      expect(document.current_edition.revision.number).to be(1)
    end

    it "sets the initial change note details" do
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition.change_note).to eq("First published.")
      expect(document.current_edition.update_type).to eq("major")
    end

    it "associates the current edition revision with the document" do
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition.revision.document).to eq(document)
    end

    it "associates the current edition status with the corresponding revision" do
      document = CreateDocumentService.call(document_type_id: document_type.id)
      revision = document.current_edition.revision
      status = document.current_edition.status
      expect(status.revision_at_creation).to eq(revision)
    end

    it "sets the political status of an edition" do
      edition = instance_double(Edition, political?: true)
      allow(PoliticalEditionIdentifier).to receive(:new).and_return(edition)
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition.system_political).to be(true)

      edition = instance_double(Edition, political?: false)
      allow(PoliticalEditionIdentifier).to receive(:new).and_return(edition)
      document = CreateDocumentService.call(document_type_id: document_type.id)
      expect(document.current_edition.system_political).to be(false)
    end

    it "can have content_id and locale specified" do
      content_id = SecureRandom.uuid
      locale = "fr"
      document = CreateDocumentService.call(content_id: content_id,
                                            document_type_id: document_type.id,
                                            locale: locale)

      expect(document.content_id).to eq(content_id)
      expect(document.locale).to eq(locale)
    end

    it "can be attributed to a user" do
      user = create(:user)
      document = CreateDocumentService.call(document_type_id: document_type.id,
                                            user: user)

      expect(document.created_by).to eq(user)
      expect(document.current_edition.created_by).to eq(user)
      expect(document.current_edition.last_edited_by).to eq(user)
      expect(document.current_edition.status.created_by).to eq(user)

      revision = document.current_edition.revision
      expect(revision.created_by).to eq(user)
      expect(revision.content_revision.created_by).to eq(user)
      expect(revision.metadata_revision.created_by).to eq(user)
      expect(revision.tags_revision.created_by).to eq(user)
    end

    it "can set tags on the current edition" do
      tags = { "primary_publishing_organisation" => [SecureRandom.uuid] }
      document = CreateDocumentService.call(document_type_id: document_type.id,
                                            tags: tags)

      expect(document.current_edition.tags).to eq(tags)
    end
  end
end
