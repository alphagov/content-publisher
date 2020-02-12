class CreateDocumentService < ApplicationService
  def initialize(content_id: SecureRandom.uuid,
                 document_type_id:,
                 locale: "en",
                 user: nil,
                 tags: {})
    @content_id = content_id
    @document_type_id = document_type_id
    @locale = locale
    @user = user
    @tags = tags
  end

  def call
    Document.transaction do
      Document.create!(
        content_id: content_id,
        locale: locale,
        created_by: user,
      ).tap { |d| create_edition(d) }
    end
  end

private

  attr_reader :content_id, :document_type_id, :locale, :user, :tags

  def create_edition(document)
    revision = build_revision(document)

    edition = Edition.new(
      document: document,
      revision: revision,
      status: build_status(revision),
      created_by: user,
      current: true,
      last_edited_by: user,
      number: 1,
    )

    edition.system_political = PoliticalEditionIdentifier.new(edition).political?
    edition.save!

    edition
  end

  def build_revision(document)
    Revision.new(
      created_by: user,
      document: document,
      number: 1,
      content_revision: ContentRevision.new(created_by: user),
      metadata_revision: MetadataRevision.new(
        change_note: "First published.",
        update_type: "major",
        created_by: user,
        document_type_id: document_type_id,
      ),
      tags_revision: TagsRevision.new(tags: tags, created_by: user),
    )
  end

  def build_status(revision)
    Status.new(
      created_by: user,
      revision_at_creation: revision,
      state: :draft,
    )
  end
end
