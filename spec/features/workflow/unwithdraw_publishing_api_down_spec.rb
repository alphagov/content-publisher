# frozen_string_literal: true

RSpec.feature "Unwithdraw when Publishing API is down" do
  scenario do
    given_there_is_a_withdrawn_edition
    and_i_am_a_managing_editor
    and_the_publishing_api_is_down
    when_i_visit_the_summary_page
    and_i_click_on_undo_withdraw_and_confirm
    then_i_see_an_error_message
    and_the_edition_is_still_withdrawn
  end

  def given_there_is_a_withdrawn_edition
    @edition = create(:edition, :withdrawn)
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, :managing_editor))
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_undo_withdraw_and_confirm
    click_on "Undo withdrawal"
    click_on "Yes, undo withdrawal"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(
      I18n.t!("documents.show.flashes.unwithdraw_error.title"),
    )
  end

  def and_the_edition_is_still_withdrawn
    expect(page).to have_content(I18n.t!("user_facing_states.withdrawn.name"))
  end
end
