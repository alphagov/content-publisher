# frozen_string_literal: true

RSpec.feature "Index details" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_index_page
    then_i_can_see_the_edition
  end

  def given_there_is_an_edition
    @edition = create(:edition,
                      last_edited_by: current_user,
                      created_by: current_user)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_can_see_the_edition
    expect(page).to have_content(@edition.title)
    expect(page).to have_content(@edition.document_type.label)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(
      I18n.t!("documents.index.search_results.last_edited_by", user: current_user.name),
    )
  end
end
