class WhitehallMigration::DocumentExport
  def self.exportable_documents
    @exportable_documents ||= Document
      .includes(:live_edition)
      .select do |document|
        document.live_edition && document.live_edition.state != "removed"
      end
  end

  def self.export_to_hash(document)
    content_revision = document.live_edition.revision.content_revision

    {
      content_id: document[:content_id],
      state: document.live_edition.state,
      created_at: document[:created_at],
      first_published_at: PublishingApiPayload::History.new(document.live_edition).first_published_at,
      updated_at: document[:updated_at],
      created_by: User.find(document.created_by_id).email,
      last_edited_by: User.find(document.live_edition.revision.created_by_id).email,
      document_type: document.live_edition.revision.metadata_revision.document_type_id,
      title: content_revision.title,
      base_path: content_revision.base_path,
      summary: content_revision.summary,
      body: content_revision.contents["body"],
      tags: document.live_edition.revision.tags_revision.tags,
      political: document.live_edition.political?,
      government_id: document.live_edition.government_id,
      change_notes: change_notes(document),
      internal_history: internal_history(document),
      images: export_images(document),
      attachments: export_attachments(document),
    }
  end

  def self.change_notes(document)
    PublishingApiPayload::History.new(document.live_edition).change_history
  end

  def self.internal_history(document)
    timeline_entries = TimelineEntry.where(document:)
      .includes(:created_by, :details)
      .order(created_at: :desc)
      .includes(:edition)

    timeline_entries.map do |entry|
      entry_content = if entry.internal_note? && entry.details
                        entry.details.body
                      elsif (entry.withdrawn? || entry.withdrawn_updated?) && entry.details
                        entry.details.public_explanation
                      end

      {
        edition_number: entry.edition.number,
        entry_type: entry.entry_type,
        date: entry.created_at.to_fs(:date),
        time: entry.created_at.to_fs(:time),
        user: entry.created_by.email,
        entry_content:,
      }
    end
  end

  def self.export_images(document)
    revision = document.live_edition.revision
    lead_image_revision = revision.lead_image_revision
    all_image_revisions = revision.image_revisions

    all_image_revisions.map do |image_revision|
      {
        created_at: image_revision.created_at,
        caption: image_revision.caption,
        alt_text: image_revision.alt_text,
        credit: image_revision.credit,
        lead_image: image_revision == lead_image_revision,
        variants: image_revision.blob_revision.assets.map do |asset|
          {
            variant: asset.variant,
            file_url: asset.file_url,
          }
        end,
      }
    end
  end

  def self.export_attachments(document)
    revision = document.live_edition.revision
    all_file_attachment_revisions = revision.file_attachment_revisions

    all_file_attachment_revisions.map do |file_attachment_revision|
      metadata = file_attachment_revision.metadata_revision
      {
        file_url: file_attachment_revision.asset.file_url,
        title: metadata.title,
        created_at: file_attachment_revision.created_at,
      }
    end
  end
end
