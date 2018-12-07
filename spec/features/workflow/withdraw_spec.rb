# frozen_string_literal: true

RSpec.feature "Withdraw a document" do
  scenario do
    given_there_is_a_published_edition
    when_i_visit_the_summary_page
    and_i_click_on_withdraw
    then_i_see_that_i_can_withdraw_the_document
    when_i_fill_in_the_public_explanation
    and_click_on_withdraw_document
    then_i_see_the_document_has_been_withdrawn
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_that_i_can_withdraw_the_document
    expect(page).to have_content "Withdraw '#{@edition.title}'"
  end

  def when_i_fill_in_the_public_explanation
    @explanation = "An explanation using [markdown](https://www.gov.uk)"
    fill_in "public_explanation", with: @explanation
  end

  def and_click_on_withdraw_document
    body = { type: "withdrawal", explanation: @explanation, locale: @edition.locale }
    stub_publishing_api_unpublish(@edition.content_id, body: body)
    click_on "Withdraw document"
  end

  def then_i_see_the_document_has_been_withdrawn
    expect(page).to have_content(I18n.t!("user_facing_states.withdrawn.name"))
  end
end
