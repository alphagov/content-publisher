class CollectionItems::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :collection,
           :revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_remove_item
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    context.collection = edition.document_type.collections[params[:collection_id]]

    assert_edition_feature(edition, assertion: "supports requested collection") do
      collection.present?
    end
  end

  def find_and_remove_item
    # should raise an exception for missing item

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(collection.updater_params_for_removed_item(edition, params[:item_id]))
    context.fail! unless updater.changed?
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
