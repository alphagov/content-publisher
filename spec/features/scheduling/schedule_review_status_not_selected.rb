# frozen_string_literal: true

RSpec.feature "Schedule with review status not selected" do
  scenario do
    given_there_is_a_schedulable_edition
    when_i_go_to_schedule_the_edition
    and_submit_without_selecting_a_review_status
    then_an_error_is_displayed
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition, :publishable, :schedulable)
  end

  def when_i_go_to_schedule_the_edition
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_submit_without_selecting_a_review_status
    click_on "Schedule"
  end

  def then_an_error_is_displayed
    expect(page)
      .to have_content(I18n.t!("requirements.schedule_action.not_selected.form_message"))
  end
end
