# frozen_string_literal: true

RSpec.feature "Unschedule an edition" do
  scenario do
    given_there_is_a_scheduled_document
    when_i_visit_the_summary_page
    and_i_click_stop_scheduled_publishing
    then_the_document_is_no_longer_scheduled
  end

  def given_there_is_a_scheduled_document
    schedule = create(:scheduling, reviewed: true)
    @edition = create(:edition, :scheduled, scheduling: schedule)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_stop_scheduled_publishing
    stub_publishing_api_destroy_intent(@edition.base_path)
    click_on "Stop scheduled publishing"
  end

  def then_the_document_is_no_longer_scheduled
    expect(page).to have_content(I18n.t!("user_facing_states.submitted_for_review.name"))

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.unscheduled")
    end
  end
end
