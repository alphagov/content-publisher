class FeaturedAttachments::UpdateOrderInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :attachments,
           :updater,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      reorder_attachments
      update_edition
      create_timeline_entry
      update_preview
    end
  end

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    assert_edition_feature(edition, assertion: "supports featured attachments") do
      edition.document_type.attachments.featured?
    end
  end

  def reorder_attachments
    new_ordering = edition.featured_attachments.sort_by do |attachment|
      ordering_params[attachment.featured_attachment_id].to_i
    end

    context.updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(featured_attachment_ordering: new_ordering.map(&:featured_attachment_id))
    context.fail! unless updater.changed?
  end

  def update_edition
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :attachments_reordered, edition:)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def ordering_params
    @ordering_params ||= params.require(:attachments).permit(ordering: {})[:ordering].to_h
  end
end
