# frozen_string_literal: true

class PoliticalEditionIdentifier
  def self.political_organisation_ids
    @political_organisation_ids ||= YAML.load_file(
      Rails.root.join("config/political_organisations.yml"),
    )
  end

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def political?
    associated_with_role_appointments? || associated_with_political_organisations?
  end

private

  def associated_with_role_appointments?
    edition.tags["role_appointments"]&.any?
  end

  def associated_with_political_organisations?
    organisation_ids = edition.supporting_organisation_ids +
      [edition.primary_publishing_organisation_id].compact

    (organisation_ids & self.class.political_organisation_ids).any?
  end
end
