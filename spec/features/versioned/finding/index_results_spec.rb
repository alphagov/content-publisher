# frozen_string_literal: true

RSpec.feature "Users views document results on index page" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_index_page
    then_i_can_see_the_document_title
    and_i_can_see_the_document_type
    and_i_can_see_the_document_state
    and_i_can_see_the_document_last_editor
  end

  def given_there_is_a_document
    @editor = create(:user)
    @edition = create(:versioned_edition, last_edited_by: @editor)
  end

  def when_i_visit_the_index_page
    visit versioned_documents_path
  end

  def then_i_can_see_the_document_title
    expect(page).to have_content(@edition.title)
  end

  def and_i_can_see_the_document_type
    expect(page).to have_content(@edition.document_type.label)
  end

  def and_i_can_see_the_document_state
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
  end

  def and_i_can_see_the_document_last_editor
    expect(page).to have_content(
      I18n.t!("documents.index.search_results.last_edited_by",
              user: @editor.name),
    )
  end
end
