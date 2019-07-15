# frozen_string_literal: true

class Withdraw::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :no_permission,
           :issues,
           :api_error,
           to: :context

  def call
    check_permission

    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      withdraw
    end
  end

private

  def check_permission
    unless user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      context.fail!(no_permission: true)
    end
  end

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    assert_edition_state(@edition, assertion: "is published or withdrawn") do
      edition.published? || edition.published_but_needs_2i? || edition.withdrawn?
    end
  end

  def check_for_issues
    issues = Requirements::WithdrawalChecker.new(params[:public_explanation], edition)
                                            .pre_withdrawal_issues
    context.fail!(issues: issues) if issues.any?
  end

  def withdraw
    WithdrawService.new.call(edition, params[:public_explanation], user)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end
end
