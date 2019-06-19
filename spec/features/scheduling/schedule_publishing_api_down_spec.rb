# frozen_string_literal: true

RSpec.feature "Schedule when Publishing API is down" do
  scenario do
    given_there_is_a_schedulable_edition
    when_i_try_to_schedule_the_edition
    and_the_publishing_api_is_down
    then_i_see_an_error_message
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition, :schedulable)
  end

  def when_i_try_to_schedule_the_edition
    visit document_path(@edition.document)
    click_on "Schedule"
    choose I18n.t!("schedule.new.review_status.reviewed")
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
    click_on "Schedule"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.schedule_error.title"))
  end
end
