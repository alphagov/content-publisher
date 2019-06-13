# frozen_string_literal: true

RSpec.feature "Schedule with requirement issues" do
  scenario do
    given_there_is_a_schedulable_edition
    when_i_try_to_schedule_it_without_a_review_status
    then_an_error_is_displayed
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition, :schedulable, :publishable)
  end

  def when_i_try_to_schedule_it_without_a_review_status
    visit document_path(@edition.document)
    click_on "Schedule"
    click_on "Schedule"
  end

  def then_an_error_is_displayed
    expect(page).to have_content(
      I18n.t!("requirements.schedule_review_status.not_selected.form_message"),
    )
  end
end
