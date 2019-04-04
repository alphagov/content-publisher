# frozen_string_literal: true

class ContentDataUrl
  # department-for-work-pensions, department-of-health-and-social-care, government-digital-service
  CONTENT_DATA_BETA_PARTNERS = %w(b548a09f-8b35-4104-89f4-f1a40bf3136d
                                  7cd6bf12-bbe9-4118-8523-f927b0442156
                                  af07d5a5-df63-4ddc-9383-6a666845ebe9).freeze

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def url
    content_data_root = Plek.new.external_url_for("content-data-admin")
    content_data_root + "/metrics" + document.live_edition.base_path
  end

  def displayable?(user)
    has_content_data_access?(user) && expected_in_content_data?
  end

private

  def has_content_data_access?(user)
    CONTENT_DATA_BETA_PARTNERS.include?(user.organisation_content_id)
  end

  def expected_in_content_data?
    # Content Data ETL runs around 7am each day and pulls in data from the
    # previous day. If content was first published yesterday we only want to
    # show a link to the content data page after the ETL has run otherwise users
    # will get a 404 page. Data Informed Content are looking at changing this so
    # this check should only be temporary.
    first_published_before_yesterday? ||
      (first_published_yesterday? && content_data_etl_end_time_elapsed?)
  end

  def first_published_yesterday?
    document.first_published_at.to_date == Date.yesterday
  end

  def first_published_before_yesterday?
    document.first_published_at.to_date < Date.yesterday
  end

  def content_data_etl_end_time_elapsed?
    # We assume that the Content Data ETL will have finished before 9am.
    Time.current.hour >= 9
  end
end
