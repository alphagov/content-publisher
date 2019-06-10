# frozen_string_literal: true

RSpec.feature "Unschedule an edition" do
  scenario do
    given_there_is_a_scheduled_document
    when_i_visit_the_summary_page
    and_i_click_stop_scheduled_publishing
    then_the_document_is_no_longer_scheduled
    and_the_proposed_schedule_is_still_set
  end

  def given_there_is_a_scheduled_document
    scheduling = create(:scheduling, reviewed: true)
    @datetime = Time.current.tomorrow.change(hour: 23)

    @edition = create(:edition,
                      :scheduled,
                      scheduled_publishing_datetime: @datetime,
                      scheduling: scheduling)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_stop_scheduled_publishing
    @request = stub_publishing_api_destroy_intent(@edition.base_path)
    click_on "Stop scheduled publishing"
  end

  def then_the_document_is_no_longer_scheduled
    expect(page).to have_content(I18n.t!("user_facing_states.submitted_for_review.name"))
    expect(page).to have_content I18n.t!("documents.history.entry_types.unscheduled")
    expect(@request).to have_been_requested
  end

  def and_the_proposed_schedule_is_still_set
    scheduled_date = @datetime.strftime("%-d %B %Y")

    expect(page).to have_content(I18n.t!("documents.show.scheduling.notice.proposed",
                                         time: "11:00pm",
                                         date: scheduled_date))
  end
end
