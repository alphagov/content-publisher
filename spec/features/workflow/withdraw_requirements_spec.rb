# frozen_string_literal: true

RSpec.feature "Withdrawal document requirements" do
  scenario do
    given_there_is_a_published_edition
    and_i_have_the_managing_editor_permission
    when_i_visit_the_document_withdrawal_page
    and_i_click_withdraw_document
    then_i_see_an_error_to_enter_an_public_explanation
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def and_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_document_withdrawal_page
    visit withdraw_path(@edition.document)
  end

  def and_i_click_withdraw_document
    click_on "Withdraw document"
  end

  def then_i_see_an_error_to_enter_an_public_explanation
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.public_explanation.blank.form_message"))
    end
  end
end
