class CollectionItems::UpdateOrderInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :collection,
           :updater,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      reorder_collection_items
      update_edition
      create_timeline_entry
      update_preview
    end
  end

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    context.collection = edition.document_type.collections[params[:collection_id]]

    assert_edition_feature(edition, assertion: "supports requested collection") do
      collection.present?
    end
  end

  def reorder_collection_items
    new_ordering = edition.contents[collection.id].dup.sort_by do |item|
      ordering_params[item["id"]].to_i
    end

    context.updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(contents: { collection.id => new_ordering })
    context.fail! unless updater.changed?
  end

  def update_edition
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def ordering_params
    @ordering_params ||= params.require(:collection).permit(ordering: {})[:ordering].to_h
  end
end
