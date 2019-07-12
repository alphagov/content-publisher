# frozen_string_literal: true

class Unwithdraw::UnwithdrawInteractor < ApplicationInteractor
  delegate :params, :user, :edition, :api_error, to: :context

  def call
    Edition.transaction do
      check_permissions
      find_and_lock_edition
      unwithdraw
    end
  end

private

  def check_permissions
    assert_permission(user, User::MANAGING_EDITOR_PERMISSION)
  end

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def unwithdraw
    UnwithdrawService.new.call(edition, user)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end
end
