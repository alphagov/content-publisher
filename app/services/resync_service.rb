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
    )
  end
end
