# frozen_string_literal: true

RSpec.feature "Set scheduled publishing datetime without selecting scheduling action" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_click_continue
    then_i_see_an_error_about_not_selecting_a_scheduling_option
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_an_error_about_not_selecting_a_scheduling_option
    expect(page).to have_content(
      I18n.t!("requirements.schedule_action.not_selected.form_message"),
    )
  end
end
