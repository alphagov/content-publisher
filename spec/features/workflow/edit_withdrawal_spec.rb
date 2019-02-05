# frozen_string_literal: true

RSpec.feature "Edit a withdrawal" do
  scenario do
    given_there_is_a_withdrawn_edition
    and_i_have_the_managing_editor_permission
    when_i_visit_the_summary_page
    and_i_click_to_change_the_public_explanation
    then_i_can_see_the_existing_public_explanation
    and_i_can_edit_the_public_explanation
  end

  def given_there_is_a_withdrawn_edition
    @edition = create(:edition, :withdrawn)
  end

  def and_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_to_change_the_public_explanation
    click_on "Change public explanation"
  end

  def then_i_can_see_the_existing_public_explanation
    expect(page).to have_field("public_explanation", with: @edition.status.details.public_explanation)
  end

  def and_i_can_edit_the_public_explanation
    new_explanation = "Another explanation"
    converted_explanation = GovspeakDocument.new(new_explanation, @edition).payload_html
    body = { type: "withdrawal", explanation: converted_explanation, locale: @edition.locale }
    stub_publishing_api_unpublish(@edition.content_id, body: body)

    fill_in "public_explanation", with: new_explanation
    click_on "Withdraw document"

    expect(@edition.reload.status.details.public_explanation).to eq(new_explanation)
  end
end
