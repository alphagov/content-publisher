# frozen_string_literal: true

class PoliticalAssociationService < ApplicationService
  def initialize(edition, fallback_government: nil)
    @edition = edition
    @fallback_government = fallback_government
  end

  def call
    edition.assign_attributes(
      government_id: government&.content_id,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
    )

    edition.update!(revision_synced: false) if edition.changed?
  end

private

  attr_reader :edition, :fallback_government

  def government
    date = edition.backdated_to || edition.document.first_published_at
    date ? Government.for_date(date) : fallback_government
  end
end
