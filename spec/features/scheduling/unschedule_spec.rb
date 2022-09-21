RSpec.feature "Unschedule" do
  around do |example|
    travel_to(Time.zone.parse("2019-06-13")) { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_stop_scheduled_publishing
    then_the_edition_is_no_longer_scheduled
    and_the_proposed_publish_time_is_still_set
    and_i_see_the_timeline_entry
  end

  def given_there_is_a_scheduled_edition
    @scheduling = create(:scheduling,
                         reviewed: true,
                         publish_time: Time.zone.parse("2019-06-14 23:00"))

    @edition = create(:edition, :scheduled, scheduling: @scheduling)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_stop_scheduled_publishing
    @destroy_intent_request = stub_publishing_api_destroy_intent(@edition.base_path)
    click_on "Stop scheduled publishing"
  end

  def then_the_edition_is_no_longer_scheduled
    expect(@destroy_intent_request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.submitted_for_review.name"))
  end

  def and_the_proposed_publish_time_is_still_set
    expect(page)
      .to have_content(I18n.t!("documents.show.proposed_scheduling_notice.title",
                               datetime: @scheduling.publish_time.to_fs(:time_on_date)))
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.unscheduled")
  end
end
