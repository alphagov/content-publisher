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
  end

private

  attr_reader :edition, :user, :attributes
end
