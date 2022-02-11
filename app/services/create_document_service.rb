class CreateDocumentService
  include Callable

  def initialize(document_type_id:,
                 content_id: SecureRandom.uuid,
                 locale: "en",
                 user: nil)
    @content_id = content_id
    @document_type_id = document_type_id
    @locale = locale
    @user = user
  end

  def call
    Document.transaction do
      Document.create!(
        content_id:,
        locale:,
        created_by: user,
      ).tap { |d| create_edition(d) }
    end
  end

private

  attr_reader :content_id, :document_type_id, :locale, :user

  def create_edition(document)
    revision = build_revision(document)

    edition = Edition.new(
      document:,
      revision:,
      created_by: user,
      current: true,
      last_edited_by: user,
      number: 1,
    )

    edition.revision = apply_default_data(edition)
    edition.status = build_status(edition.revision)

    edition.system_political = PoliticalEditionIdentifier.new(edition).political?
    edition.save!

    edition
  end

  def build_revision(document)
    Revision.new(
      created_by: user,
      document:,
      number: 1,
      content_revision: ContentRevision.new(created_by: user),
      metadata_revision: MetadataRevision.new(
        update_type: "major",
        created_by: user,
        document_type_id:,
      ),
      tags_revision: TagsRevision.new(created_by: user),
    )
  end

  def build_status(revision)
    Status.new(
      created_by: user,
      revision_at_creation: revision,
      state: :draft,
    )
  end

  def apply_default_data(edition)
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    fields = edition.document_type.contents

    content_params = fields.reduce({}) do |hash, field|
      hash.deep_merge!(field.updater_params(edition, {}))
    end

    updater.assign(content_params)
    updater.next_revision
  end
end
