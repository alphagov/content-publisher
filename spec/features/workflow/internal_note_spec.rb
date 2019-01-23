# frozen_string_literal: true

RSpec.feature "Creating a internal note" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_fill_in_and_submit_a_internal_note
    then_i_should_see_the_internal_note

    and_i_submit_a_blank_internal_note
    then_no_internal_note_is_created
  end

  def given_there_is_a_document
    @document = create(:document, :with_current_edition)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_fill_in_and_submit_a_internal_note
    fill_in "internal_note", with: "Belvita's are incredible"
    click_on I18n.t!("documents.history.add_internal_note")
  end

  def then_i_should_see_the_internal_note
    within("#document-history") do
      expect(page).to have_content(I18n.t!("documents.history.entry_types.internal_note"))
      expect(page).to have_content(@document.timeline_entries.last.details.body)
    end
  end

  def and_i_submit_a_blank_internal_note
    fill_in "internal_note", with: ""
    click_on I18n.t!("documents.history.add_internal_note")
  end

  def then_no_internal_note_is_created
    expect(@document.timeline_entries.last.details.body).to_not eq("")
  end
end
