# frozen_string_literal: true

class UnwithdrawService
  def call(edition, user = nil)
    raise "edition must be withdrawn to be unwithdrawn" unless edition.withdrawn?

    withdrawal = edition.status.details
    published_status = withdrawal.published_status

    edition.assign_status(published_status.state, user)
    edition.save!

    TimelineEntry.create_for_status_change(
      entry_type: :unwithdrawn,
      status: edition.status,
    )

    GdsApi.publishing_api_v2.republish(
      edition.content_id,
      locale: "en",
    )
  end
end
