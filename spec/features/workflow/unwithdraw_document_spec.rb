# frozen_string_literal: true

RSpec.feature "Unwithdraw a document" do
  scenario do
    given_there_is_a_withdrawn_document
    when_i_visit_the_document_page
    and_i_click_on_undo_withdraw
    then_i_see_the_feature_is_currently_unavailable
  end

  def given_there_is_a_withdrawn_document
    @document = create(:document, :retired)
    timeline_entry = create(:timeline_entry, entry_type: "retired", document_id: @document.id)
    create(:retirement, timeline_entry: timeline_entry)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_undo_withdraw
    click_on "Undo withdraw"
  end

  def then_i_see_the_feature_is_currently_unavailable
    expect(page).to have_content("Sorry, this hasn't been built yet")
  end
end
