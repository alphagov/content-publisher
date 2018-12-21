# frozen_string_literal: true

RSpec.feature "Withdraw a document" do
  scenario do
    given_there_is_a_published_document
    when_i_visit_the_document_page
    and_i_click_on_withdraw
    then_i_see_that_i_can_withdraw_the_document
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_that_i_can_withdraw_the_document
    expect(page).to have_content "Withdraw '#{@document.title}'"
  end
end
