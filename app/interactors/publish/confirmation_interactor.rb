# frozen_string_literal: true

class Publish::ConfirmationInteractor < ApplicationInteractor
  delegate :user,
           :params,
           :edition,
           :api_error,
           :issues,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def check_for_issues
    issues = Requirements::EditionChecker.new(edition)
                                         .pre_publish_issues(rescue_api_errors: false)

    context.fail!(issues: issues) if issues.any?
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end
end
