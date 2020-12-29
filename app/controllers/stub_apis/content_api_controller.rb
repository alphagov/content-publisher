# NOTE this is intentionally not compatible with GOV.UK's Content Store API
# It's just intended to prove the concept that this application could function
# as a monolithic Headless CMS.
class StubApis::ContentApiController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def contents
    render json: live_edition_details
  end

  private

  def live_edition_details
    Edition
      .includes(:document, :revision)
      .where(live: true, current: true)
      .map do |edition|
        {
          title: edition.title,
          base_path: edition.base_path,
          body: edition.contents["body"],
          summary: edition.summary,
          content_id: edition.content_id,
          first_published: edition.public_first_published_at,
        }
      end
  end
end
