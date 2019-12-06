# frozen_string_literal: true

class EditEditionService < ApplicationService
  def initialize(edition, user, **attributes)
    @edition = edition
    @user = user
    @attributes = attributes
  end

  def call
    raise "cannot edit a live edition" if edition.live?

    edition.assign_attributes(
      attributes.merge(last_edited_by: user, last_edited_at: Time.current),
    )

    determine_political
    associate_with_government
  end

private

  attr_reader :edition, :user, :attributes

  def determine_political
    identifier = PoliticalEditionIdentifier.new(edition)
    edition.system_political = identifier.political?
  end

  def associate_with_government
    edition.government_id = Government.for_date(edition.public_first_published_at)&.content_id
  end
end
