class PublishDraftEditionService < ApplicationService
  def initialize(edition, user, with_review:)
    @edition = edition
    @user = user
    @with_review = with_review
  end

  def call
    raise "Only a current edition can be published" unless edition.current?
    raise "Live editions cannot be published" if edition.live?

    publish_assets
    associate_with_government
    publish_current_edition
    supersede_live_edition
    set_new_live_edition
    set_first_published_at
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  attr_reader :edition, :user, :with_review
  delegate :document, to: :edition

  def publish_assets
    PublishAssetsService.call(edition, superseded_edition: document.live_edition)
  end

  def associate_with_government
    return if edition.government

    repository = BulkData::GovernmentRepository.new
    government = if edition.public_first_published_at
                   repository.for_date(edition.public_first_published_at)
                 else
                   repository.current
                 end
    edition.assign_attributes(government_id: government&.content_id)

    # We need to update the Publishing API if we're changing the government
    PreviewDraftEditionService.call(edition) if edition.government_id_changed?
  end

  def publish_current_edition
    GdsApi.publishing_api.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )
  end

  def supersede_live_edition
    live_edition = document.live_edition
    return unless live_edition

    AssignEditionStatusService.call(live_edition,
                                    user: user,
                                    state: :superseded,
                                    record_edit: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition
    state = with_review ? :published : :published_but_needs_2i
    AssignEditionStatusService.call(edition, user: user, state: state)
    edition.access_limit = nil
    edition.live = true
    edition.save!
    document.reload_live_edition
  end

  def set_first_published_at
    return if document.first_published_at

    document.update!(first_published_at: Time.current)
  end
end
