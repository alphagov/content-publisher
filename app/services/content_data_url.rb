# frozen_string_literal: true

class ContentDataUrl
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def url
    content_data_root = Plek.new.external_url_for("content-data")
    content_data_root + "/metrics" + document.live_edition.base_path
  end

  def displayable?
    expected_in_content_data?
  end

private

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
