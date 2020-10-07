class Preview::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :preview_failed,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      create_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, assertion: "not live") { !edition.live? }
  end

  def check_for_issues
    issues = Requirements::Preview::EditionChecker.call(edition)
    context.fail!(issues: issues) if issues.any?
  end

  def create_preview
    PreviewDraftEditionService.call(edition)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(preview_failed: true)
  end
end
