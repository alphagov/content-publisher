# frozen_string_literal: true

RSpec.feature "Schedule an edition with requirements issues" do
  scenario "publishing requirements" do
    given_there_is_an_edition_with_publish_issues
    when_i_visit_the_summary_page
    then_i_see_a_warning_to_fix_the_publish_issues
    and_i_click_schedule
    then_i_see_an_error_to_fix_the_publish_issues
  end

  scenario "publish time too close" do
    given_there_is_an_edition_to_publish_too_soon
    when_i_visit_the_summary_page
    then_i_see_an_error_to_reschedule_later_on
    and_i_click_schedule
    then_i_see_an_error_to_reschedule_later_on
  end

  scenario "publish time in the past" do
    given_there_is_an_edition_to_publish_in_the_past
    when_i_visit_the_summary_page
    then_i_see_an_error_to_reschedule_in_the_future
    and_i_click_schedule
    then_i_see_an_error_to_reschedule_in_the_future
  end

  def given_there_is_an_edition_with_publish_issues
    @edition = create(:edition, proposed_publish_time: Date.tomorrow.noon)
  end

  def given_there_is_an_edition_to_publish_too_soon
    @edition = create(:edition,
                      :publishable,
                      proposed_publish_time: Time.current.advance(minutes: 5))
  end

  def given_there_is_an_edition_to_publish_in_the_past
    @edition = create(:edition, :publishable, proposed_publish_time: 1.day.ago)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_schedule
    click_on "Schedule"
  end

  def then_i_see_an_error_to_fix_the_publish_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end

  def then_i_see_a_warning_to_fix_the_publish_issues
    within(".app-c-inset-prompt") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end

  def then_i_see_an_error_to_reschedule_later_on
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.schedule_time.too_close_to_now.summary_message"))
    end
  end

  def then_i_see_an_error_to_reschedule_in_the_future
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.schedule_date.in_the_past.summary_message"))
    end
  end
end
