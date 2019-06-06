# frozen_string_literal: true

RSpec.feature "Schedule an edition that has been submitted for 2i" do
  scenario do
    given_there_is_an_edition_submitted_for_2i
    when_i_visit_the_summary_page
    and_i_click_schedule_to_publish
    and_i_select_the_reviewed_option
    then_i_see_the_edition_has_been_scheduled
    and_i_can_no_longer_edit_the_content
  end

  def given_there_is_an_edition_submitted_for_2i
    @datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition,
                      scheduled_publishing_datetime: @datetime,
                      state: "submitted_for_review")
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_schedule_to_publish
    click_on "Schedule to publish"
  end

  def and_i_select_the_reviewed_option
    stub_default_publishing_api_put_intent
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_has_been_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))

    scheduled_date = @datetime.strftime("%-d %B %Y")
    expect(page).to have_content("Scheduled to publish at 10:00am on #{scheduled_date}")
  end

  def and_i_can_no_longer_edit_the_content
    expect(page).not_to have_link("Change Content")
  end
end
