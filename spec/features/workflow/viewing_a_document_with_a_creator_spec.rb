# frozen_string_literal: true

RSpec.feature "Viewing a document with a creator" do
  scenario "User finds document with a creator and views it" do
    given_there_is_a_document_with_a_creator
    when_i_visit_the_index_page
    then_i_see_who_created_that_document
    when_i_visit_the_document_page
    then_i_again_see_who_created_the_document
  end

  def given_there_is_a_document_with_a_creator
    @user = create(:user, name: "Joe Bloggs")
    @document = create(:document, creator: @user)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_see_who_created_that_document
    expect(page).to have_content(@document.title)
    expect(page).to have_content(@user.name)
  end

  def when_i_visit_the_document_page
    click_on @document.title
  end

  def then_i_again_see_who_created_the_document
    expect(page).to have_content(
      I18n.t("documents.show.metadata.created_by") + ": " + @user.name,
    )
    expect(page).to have_content(
      I18n.t("documents.show.metadata.last_edited_by") + ": " + @user.name,
    )
  end
end
