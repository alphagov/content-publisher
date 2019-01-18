# frozen_string_literal: true

RSpec.feature "Viewing a document with no creator or editor" do
  scenario do
    given_there_is_a_document_with_no_creator
    when_i_visit_the_index_page
    then_i_see_the_document_has_no_last_editor
    when_i_visit_the_document_page
    then_i_again_see_we_dont_know_who_created_the_document
    and_i_again_see_the_document_has_no_last_editor
  end

  def given_there_is_a_document_with_no_creator
    document = create(:versioned_document, created_by: nil)
    @edition = create(:versioned_edition, document: document, last_edited_by: nil)
  end

  def when_i_visit_the_index_page
    visit versioned_documents_path
  end

  def then_i_see_the_document_has_no_last_editor
    expect(page).to have_content(
      I18n.t!("documents.index.search_results.last_edited_by",
        user: I18n.t!("documents.index.search_results.unknown_user")),
    )
  end

  def when_i_visit_the_document_page
    click_on @edition.title
  end

  def then_i_again_see_we_dont_know_who_created_the_document
    expect(page).to have_content(
      I18n.t!("documents.show.metadata.created_by") + ": " +
      I18n.t!("documents.show.metadata.unknown_user"),
    )
  end

  def and_i_again_see_the_document_has_no_last_editor
    expect(page).to have_content(
      I18n.t!("documents.show.metadata.last_edited_by") + ": " +
      I18n.t!("documents.show.metadata.unknown_user"),
    )
  end
end
