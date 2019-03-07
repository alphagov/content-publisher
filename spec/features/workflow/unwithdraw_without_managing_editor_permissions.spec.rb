# frozen_string_literal: true

RSpec.feature "Undo a withdraw without managing editor permission" do
  scenario "withdrawn edition" do
    given_i_am_not_a_managing_editor
    when_there_is_a_withdrawn_edition
    and_i_visit_the_withdrawn_document_summary_page
    and_i_click_on_undo_withdrawal
    then_i_see_a_message_to_ask_my_managing_editor_to_unwithdraw_content
  end

  def given_i_am_not_a_managing_editor
    login_as(create(:user))
  end

  def when_there_is_a_withdrawn_edition
    @withdrawn_edition = create(:edition, :withdrawn)
    create(:timeline_entry, entry_type: :withdrawn, details: @withdrawn_edition.status.details)
  end

  def and_i_visit_the_withdrawn_document_summary_page
    visit document_path(@withdrawn_edition.document)
  end

  def and_i_click_on_undo_withdrawal
    click_on "Undo withdrawal"
  end

  def then_i_see_a_message_to_ask_my_managing_editor_to_unwithdraw_content
    expect(page).to have_content(
      I18n.t!("unwithdraw.no_managing_editor_permission.title"),
    )
  end
end
