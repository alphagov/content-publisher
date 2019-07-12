# frozen_string_literal: true

RSpec.feature "Withdraw a document when Publishing API is down" do
  scenario do
    given_there_is_a_published_edition
    and_i_am_a_managing_editor
    and_the_publishing_api_is_down
    when_i_visit_the_summary_page
    and_i_try_to_withdraw_an_edition
    then_i_see_a_withdrawal_error_message
    and_the_document_has_not_been_withdrawn
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, :managing_editor))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_try_to_withdraw_an_edition
    click_on "Withdraw"
    fill_in "public_explanation", with: "An explanation"
    click_on "Withdraw document"
  end

  def then_i_see_a_withdrawal_error_message
    expect(page).to have_content(I18n.t!("withdraw.new.flashes.publishing_api_error.title"))
  end

  def and_the_document_has_not_been_withdrawn
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
  end
end
