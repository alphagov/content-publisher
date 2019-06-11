# frozen_string_literal: true

RSpec.feature "Propose schedule without selecting an action" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_click_continue
    then_an_error_is_displayed
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
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

  def then_an_error_is_displayed
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.schedule_action.not_selected.form_message"))
    end
  end
end
