# frozen_string_literal: true

RSpec.feature "Viewing a document with no creator" do
  scenario "User finds document without a creator and views it" do
    given_there_is_a_document_with_no_creator
    when_i_visit_the_index_page
    then_i_see_we_dont_know_who_created_the_document
    when_i_visit_the_document_page
    then_i_again_see_we_dont_know_who_created_the_document
  end

  def given_there_is_a_document_with_no_creator
    @document = create(:document, creator: nil)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_see_we_dont_know_who_created_the_document
    expect(page).to have_content(@document.title)
    expect(page).to have_content(
      I18n.t("documents.index.search_results.unknown_creator"),
    )
  end

  def when_i_visit_the_document_page
    click_on @document.title
  end

  def then_i_again_see_we_dont_know_who_created_the_document
    expect(page).to have_content(
      I18n.t("documents.show.metadata.created_by") + ": " +
      I18n.t("documents.show.metadata.unknown_creator"),
    )
  end
end
