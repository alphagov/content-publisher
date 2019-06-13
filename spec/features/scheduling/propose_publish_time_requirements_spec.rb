# frozen_string_literal: true

RSpec.feature "Propose publish time with requirements issues" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_i_fill_in_the_form_incorrently
    then_i_see_errors_for_the_issues
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_go_to_propose_a_publish_time
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_fill_in_the_form_incorrently
    # a required action option is not selected
    click_on "Continue"
  end

  def then_i_see_errors_for_the_issues
    expect(page)
      .to have_content(I18n.t!("requirements.schedule_action.not_selected.form_message"))
  end
end
