# frozen_string_literal: true

RSpec.feature "Document withdrawl requirements" do
  scenario do
    given_there_is_a_published_document
    given_i_have_the_managing_editor_permission
    when_i_visit_the_document_withdrawal_page
    and_i_click_withdraw_document
    then_i_see_an_error_to_enter_an_public_explanation

    when_i_enter_an_public_explanation_that_is_too_long
    and_i_click_withdraw_document
    then_i_see_an_error_to_enter_a_shorter_public_explanation
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def given_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_document_withdrawal_page
    visit withdraw_path(@document)
  end

  def and_i_click_withdraw_document
    click_on "Withdraw document"
  end

  def then_i_see_an_error_to_enter_an_public_explanation
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.public_explanation.blank.form_message"))
    end
  end

  def when_i_enter_an_public_explanation_that_is_too_long
    fill_in "public_explanation", with: "a" * (Requirements::PublicExplanationChecker::PUBLIC_EXPLANATION_MAX_LENGTH + 1)
  end

  def then_i_see_an_error_to_enter_a_shorter_public_explanation
    within(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t!(
          "requirements.public_explanation.too_long.form_message",
          max_length: Requirements::PublicExplanationChecker::PUBLIC_EXPLANATION_MAX_LENGTH,
        ),
      )
    end
  end
end
