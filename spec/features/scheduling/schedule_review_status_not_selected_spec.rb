# frozen_string_literal: true

RSpec.feature "Schedule without confirming a review status" do
  scenario do
    given_there_is_an_edition_ready_to_schedule
    when_i_visit_the_summary_page
    and_try_and_schedule_without_selecting_a_review_status
    then_an_error_is_displayed
  end

  def given_there_is_an_edition_ready_to_schedule
    @edition = create(:edition, scheduled_publishing_datetime: Time.current.tomorrow)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_try_and_schedule_without_selecting_a_review_status
    2.times { click_on "Schedule" }
  end

  def then_an_error_is_displayed
    expect(page).to have_content(
      I18n.t!("requirements.schedule_review.not_selected.form_message"),
    )
  end
end
