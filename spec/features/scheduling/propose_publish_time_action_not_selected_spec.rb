# frozen_string_literal: true

RSpec.feature "Propose publish time with action not selected" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_submit_without_selecting_an_action
    then_an_error_is_displayed
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_go_to_propose_a_publish_time
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_submit_without_selecting_an_action
    click_on "Continue"
  end

  def then_an_error_is_displayed
    expect(page)
      .to have_content(I18n.t!("requirements.schedule_action.not_selected.form_message"))
  end
end
