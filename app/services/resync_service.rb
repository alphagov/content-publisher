# frozen_string_literal: true

class ResyncService < ApplicationService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    edition = document.current_edition
    edition.update!(
      revision_synced: false,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
      government_id: government_id(edition, document),
    )
  end

private

  def government_id(edition, document)
    date = edition.backdated_to || document.first_published_at
    return unless date

    Government.for_date(date)&.content_id
  end
end
