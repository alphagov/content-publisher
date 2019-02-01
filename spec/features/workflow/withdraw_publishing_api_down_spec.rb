# frozen_string_literal: true

RSpec.feature "Withdraw a document when Publishing API is down" do
  scenario do
    given_there_is_a_published_edition
    and_i_have_the_managing_editor_permission
    when_i_visit_the_withdraw_document_page
    and_the_publishing_api_is_down
    when_i_fill_in_the_public_explanation
    and_click_on_withdraw_document
    then_i_see_a_withdrawal_error_message
    and_the_document_has_not_been_withdrawn
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def and_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_withdraw_document_page
    visit withdraw_path(@edition.document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_fill_in_the_public_explanation
    fill_in "public_explanation", with: "An explanation"
  end

  def and_click_on_withdraw_document
    click_on "Withdraw document"
  end

  def then_i_see_a_withdrawal_error_message
    expect(page).to have_content(I18n.t!("withdraw.new.flashes.publishing_api_error.title"))
  end

  def and_the_document_has_not_been_withdrawn
    @edition.reload
    expect(@edition.state).not_to eq("withdrawn")
  end
end
