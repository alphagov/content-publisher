# frozen_string_literal: true

RSpec.feature "Viewing a document with a creator" do
  scenario do
    given_there_is_a_document_with_a_creator
    when_i_visit_the_index_page
    and_i_click_on_the_document_title
    then_i_see_who_created_the_document
  end

  def given_there_is_a_document_with_a_creator
    @edition = create(:edition,
                      document: build(:document, created_by: current_user),
                      created_by: current_user)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def and_i_click_on_the_document_title
    click_on @edition.title
  end

  def then_i_see_who_created_the_document
    expect(page).to have_content(
      I18n.t!("documents.show.metadata.created_by") + ": " + current_user.name,
    )
  end
end
