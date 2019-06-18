# frozen_string_literal: true

RSpec.feature "Propose publish time" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-13")) { example.run }
  end

  scenario do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_i_use_the_default_time
    and_i_select_save_proposed_time
    then_i_see_there_is_a_proposed_publish_time
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_go_to_propose_a_publish_time
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_use_the_default_time
    expect(page).to have_field("schedule[date][day]", with: "14")
    expect(page).to have_field("schedule[date][month]", with: "6")
    expect(page).to have_field("schedule[date][year]", with: "2019")
    expect(page).to have_field("schedule[time]", with: "9:00am")
  end

  def and_i_select_save_proposed_time
    choose "Save proposed date and time"
    click_on "Continue"
  end

  def then_i_see_there_is_a_proposed_publish_time
    expect(page)
      .to have_content(I18n.t!("documents.show.proposed_scheduling_notice.title",
                               time: "9:00am",
                               date: "14 June 2019"))
  end
end
