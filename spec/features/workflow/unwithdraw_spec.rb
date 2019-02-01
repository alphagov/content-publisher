# frozen_string_literal: true

RSpec.feature "Unwithdraw a document" do
  scenario do
    given_there_is_a_withdrawn_document
    when_i_visit_the_summary_page
    and_i_click_on_undo_withdraw
    then_i_see_the_feature_is_currently_unavailable
  end

  def given_there_is_a_withdrawn_document
    @edition = create(:edition, :withdrawn)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_undo_withdraw
    click_on "Undo withdrawal"
  end

  def then_i_see_the_feature_is_currently_unavailable
    expect(page).to have_content("Sorry, this hasn't been built yet")
  end
end
