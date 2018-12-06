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
    creator = create(:user)
    editor = create(:user)
    create(:document, creator: creator, last_editor: editor)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_can_see_the_document_title
    expect(page).to have_content(Document.last.title)
  end

  def and_i_can_see_the_document_type
    expect(page).to have_content(Document.last.document_type_schema.label)
  end

  def and_i_can_see_the_document_state
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
  end

  def and_i_can_see_the_document_last_editor
    expect(page).to have_content(
      I18n.t!("documents.index.search_results.last_edited_by",
        user: Document.last.last_editor.name),
    )
  end
end
