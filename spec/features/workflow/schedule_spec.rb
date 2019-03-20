# frozen_string_literal: true

RSpec.feature "Schedule an edition" do
  scenario do
    given_there_is_an_edition_with_set_scheduled_publishing_datetime
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_select_the_content_has_been_reviewed_option
    and_i_click_on_publish
    then_i_see_a_confirmation_that_the_edition_has_been_scheduled

    when_i_visit_the_summary_page
    then_i_see_the_edition_has_been_scheduled
    and_i_can_no_longer_see_a_schedule_action
    and_i_can_no_longer_edit_the_content
  end

  def given_there_is_an_edition_with_set_scheduled_publishing_datetime
    @datetime = Time.current.tomorrow
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
    @request = stub_default_publishing_api_put_intent
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_select_the_content_has_been_reviewed_option
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
  end

  def and_i_click_on_publish
    click_on "Publish"
  end

  def then_i_see_a_confirmation_that_the_edition_has_been_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))

    govuk_header_args = an_instance_of(Hash) # args from govuk_sidekiq gem
    expect(ScheduledPublishingWorker)
      .to have_enqueued_sidekiq_job(@edition.id, govuk_header_args)
      .at(@datetime)

    assert_requested @request
  end

  def then_i_see_the_edition_has_been_scheduled
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
  end

  def and_i_can_no_longer_see_a_schedule_action
    expect(page).not_to have_link("Schedule")
  end

  def and_i_can_no_longer_edit_the_content
    expect(page).not_to have_link("Change Content")
  end
end
