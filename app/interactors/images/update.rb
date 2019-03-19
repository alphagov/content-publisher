# frozen_string_literal: true

class Images::Update
  include Interactor
  delegate :params, :user, to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = update_image_revision(edition, image_params)
      check_issues(edition, image_revision)

      updater = Versioning::RevisionUpdater.new(edition.revision, user)
      updater.update_image(image_revision, params[:lead_image] == "on")

      if updater.changed?
        create_timeline_entry(edition, updater)
        edition.assign_revision(updater.next_revision, user).save!
        PreviewService.new(edition).try_create_preview
      end

      update_context(edition: edition,
                     image_revision: image_revision,
                     updater: updater)
    end
  end

private

  def update_image_revision(edition, update_params)
    image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    updater = Versioning::ImageRevisionUpdater.new(image_revision, user)
    updater.assign(update_params)
    updater.next_revision
  end

  def image_params
    params.require(:image_revision).permit(:caption, :alt_text, :credit)
  end

  def check_issues(edition, image_revision)
    checker = Requirements::ImageRevisionChecker.new(image_revision)
    issues = checker.pre_preview_metadata_issues
    if issues.any?
      context.fail!(edition: edition,
                    image_revision: image_revision,
                    issues: issues)
    end
  end

  def upload_image(image_params)
    upload_service = ImageUploadService.new(image_params, context.edition.revision)
    context.image_revision = upload_service.call(context.user)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(context.edition.revision,
                                              context.user)

    updater.update_image(context.image_revision, false)
    context.edition.assign_revision(updater.next_revision, context.user).save!
  end

  def create_timeline_entry(edition, updater)
    timeline_entry_type = if updater.selected_lead_image?
                            :lead_image_selected
                          elsif updater.removed_lead_image?
                            :lead_image_removed
                          else
                            :image_updated
                          end

    TimelineEntry.create_for_revision(entry_type: timeline_entry_type, edition: edition)
  end

  def update_context(attributes)
    attributes.each { |k, v| context[k.to_sym] = v }
  end
end
