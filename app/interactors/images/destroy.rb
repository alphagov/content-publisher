# frozen_string_literal: true

class Images::Destroy
  include Interactor
  delegate :params, :user, to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
      updater = Versioning::RevisionUpdater.new(edition.revision, user)

      updater.remove_image(image_revision)
      edition.assign_revision(updater.next_revision, user).save!

      TimelineEntry.create_for_revision(entry_type: :image_deleted,
                                        edition: edition)
      PreviewService.new(edition).try_create_preview

      update_context(edition: edition,
                     image_revision: image_revision,
                     updater: updater)
    end
  end

private

  def update_context(attributes)
    attributes.each { |k, v| context[k.to_sym] = v }
  end
end
