# frozen_string_literal: true

RSpec.feature "Index details" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_index_page
    then_i_can_see_the_title
    and_i_can_see_the_document_type
    and_i_can_see_the_state
    and_i_can_see_who_last_edited_it
  end

  def given_there_is_an_edition
    @editor = create(:user)
    @edition = create(:edition, last_edited_by: @editor)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_can_see_the_title
    expect(page).to have_content(@edition.title)
  end

  def and_i_can_see_the_document_type
    expect(page).to have_content(@edition.document_type.label)
  end

  def and_i_can_see_the_state
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
  end

  def and_i_can_see_who_last_edited_it
    expect(page).to have_content(
      I18n.t!("documents.index.search_results.last_edited_by", user: @editor.name),
    )
  end
end
