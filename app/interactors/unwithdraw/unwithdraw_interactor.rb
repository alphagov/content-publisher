# frozen_string_literal: true

class Unwithdraw::UnwithdrawInteractor
  include Interactor

  delegate :params, :user, :edition, :api_error, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      unwithdraw
    end
  end

private

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
