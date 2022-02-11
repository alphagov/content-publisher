class CollectionItems::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :collection,
           :revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      update_revision

      update_edition
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

  def update_revision
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(collection.updater_params_for_new_item(edition, params))
    context.fail! unless updater.changed?
    context.revision = updater.next_revision
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new

    context.fail!(issues: issues) if issues.any?
  end

  def fields
    @fields ||= collection.fields
  end

  def update_edition
    EditDraftEditionService.call(edition, user, revision: revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
