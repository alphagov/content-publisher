# frozen_string_literal: true

RSpec.feature "Managing editor permissions" do
  scenario do
    given_there_is_a_published_document
    when_i_dont_have_the_managing_editor_permission
    and_i_visit_the_document_page
    and_i_click_on_withdraw
    then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
    when_i_do_have_the_managing_editor_permission
    and_i_visit_the_document_page
    and_i_click_on_withdraw
    then_i_can_see_a_public_explanation_form

    given_there_is_a_withdrawn_document
    when_i_dont_have_the_managing_editor_permission
    and_i_visit_the_withdrawn_document_page
    and_i_click_on_change_public_explanation
    then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
    when_i_do_have_the_managing_editor_permission
    and_i_visit_the_withdrawn_document_page
    and_i_click_on_change_public_explanation
    then_i_can_see_a_public_explanation_form
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def when_i_dont_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_a_message_to_ask_my_managing_editor_to_withdraw_content
    expect(page).to have_content(
      "Only a managing editor can remove or withdraw a live page",
    )
  end

  def when_i_do_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def then_i_can_see_a_public_explanation_form
    expect(page).to have_field("public_explanation")
  end

  def given_there_is_a_withdrawn_document
    document = create(:document, :retired)
    timeline_entry = create(:timeline_entry, entry_type: "retired", document_id: document.id)
    create(:retirement, timeline_entry: timeline_entry)
  end

  def and_i_visit_the_withdrawn_document_page
    visit document_path(Document.last)
  end

  def and_i_click_on_change_public_explanation
    click_on "Change public explanation"
  end
end
