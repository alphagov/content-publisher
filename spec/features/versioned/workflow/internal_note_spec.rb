# frozen_string_literal: true

RSpec.feature "Displaying an internal note" do
  scenario do
    given_there_is_a_document_with_a_internal_note
    when_i_visit_the_document_page
    then_i_should_see_the_internal_note
  end

  def given_there_is_a_document_with_a_internal_note
    @edition = create(:versioned_edition)
    @internal_note = create(:versioned_internal_note,
                            body: "Belvita's are pure joy",
                            edition: @edition)
    create(:versioned_timeline_entry,
           entry_type: "internal_note",
           edition: @edition,
           details: @internal_note)
  end

  def when_i_visit_the_document_page
    visit versioned_document_path(@edition.document)
  end

  def then_i_should_see_the_internal_note
    within("#document-history") do
      expect(page).to have_content(I18n.t!("documents.history.entry_types.internal_note"))
      expect(page).to have_content(@internal_note.body)
    end
  end
end
