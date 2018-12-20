# frozen_string_literal: true

RSpec.feature "Withdraw without managing editor permission" do
  background do
    given_i_dont_have_the_managing_editor_permission
  end

  scenario "published edition" do
    when_there_is_a_published_edition
    and_i_visit_the_summary_page
    and_i_click_on_withdraw
    then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
  end

  scenario "withdrawn edition" do
    when_there_is_a_withdrawn_edition
    and_i_visit_the_withdrawn_document_summary_page
    and_i_click_on_change_public_explanation
    then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
  end

  def when_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def given_i_dont_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
    expect(page).to have_content(
      I18n.t!("withdraw.no_managing_editor_permission.title"),
    )
  end

  def when_there_is_a_withdrawn_edition
    @withdrawn_edition = create(:edition, :withdrawn)
    create(:timeline_entry, entry_type: :withdrawn, details: @withdrawn_edition.status.details)
  end

  def and_i_visit_the_withdrawn_document_summary_page
    visit document_path(@withdrawn_edition.document)
  end

  def and_i_click_on_change_public_explanation
    click_on "Change public explanation"
  end
end
