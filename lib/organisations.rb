# frozen_string_literal: true

class Organisations
  DEFAULT_ALTERNATIVE_FORMAT_CONTACT_EMAIL = "govuk-feedback@digital.cabinet-office.gov.uk"
  CACHE_OPTIONS = { expires_in: 15.minutes, race_condition_ttl: 30.seconds }.freeze

  attr_reader :edition

  def self.by_content_id(content_id)
    Rails.cache.fetch("organisations.#{content_id}", CACHE_OPTIONS) do
      GdsApi.publishing_api_v2.get_content(content_id).to_h
    end
  end

  def initialize(edition)
    @edition = edition
  end

  def alternative_format_contact_email
    return DEFAULT_ALTERNATIVE_FORMAT_CONTACT_EMAIL unless primary_org_content_id

    primary_org = self.class.by_content_id(primary_org_content_id)
    email = primary_org.dig("details", "alternative_format_contact_email")
    email.presence || DEFAULT_ALTERNATIVE_FORMAT_CONTACT_EMAIL
  rescue GdsApi::HTTPNotFound
    DEFAULT_ALTERNATIVE_FORMAT_CONTACT_EMAIL
  end

private


  def primary_org_content_id
    edition.primary_publishing_organisation_id
  end
end
