# frozen_string_literal: true

class Backdate::DestroyInteractor
  include Interactor

  delegate :params, :edition, :user, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    unless edition.editable? && edition.first?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Only editable backdated first editions can have their backdated date cleared."
    end
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: nil)
    context.fail! unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
