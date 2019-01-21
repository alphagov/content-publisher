# frozen_string_literal: true

RSpec.feature "Viewing a document with a creator" do
  scenario do
    given_there_is_a_document_with_a_creator
    when_i_visit_the_index_page
    when_i_visit_the_document_page
    then_i_see_who_created_the_document
  end

  def given_there_is_a_document_with_a_creator
    @user = create(:user, name: "Joe Bloggs")
    @document = create(:document, :with_current_edition, created_by: @user)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def when_i_visit_the_document_page
    click_on @document.current_edition_title
  end

  def then_i_see_who_created_the_document
    expect(page).to have_content(
      I18n.t!("documents.show.metadata.created_by") + ": " + @user.name,
    )
  end
end
