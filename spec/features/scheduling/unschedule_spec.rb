# frozen_string_literal: true

RSpec.feature "Unschedule" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2019-06-13 11:00") { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_stop_scheduled_publishing
    then_the_edition_is_no_longer_scheduled
    and_it_has_a_proposed_publish_time
  end

  def given_there_is_a_scheduled_edition
    scheduling = create(:scheduling,
                        reviewed: true,
                        publish_time: Time.zone.parse("2019-06-14 23:00"))

    @edition = create(:edition, :scheduled, scheduling: scheduling)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_stop_scheduled_publishing
    @request = stub_publishing_api_destroy_intent(@edition.base_path)
    click_on "Stop scheduled publishing"
  end

  def then_the_edition_is_no_longer_scheduled
    expect(page).to have_content(I18n.t!("user_facing_states.submitted_for_review.name"))
    expect(page).to have_content I18n.t!("documents.history.entry_types.unscheduled")
    expect(@request).to have_been_requested
  end

  def and_it_has_a_proposed_publish_time
    expect(page).to have_content(I18n.t!("documents.show.scheduling.notice.proposed",
                                         time: "11:00pm",
                                         date: "14 June 2019"))
  end
end
