RSpec.describe "Create a document" do
  it do
    given_i_am_on_the_home_page
    when_i_click_to_create_a_document
    and_i_select_a_supertype
    and_i_select_a_document_type
    and_i_fill_in_the_contents
    then_i_see_the_document_summary
    and_i_see_the_timeline_entry
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def when_i_click_to_create_a_document
    @document_type = build :document_type
    click_on "Create new document"
  end

  def and_i_select_a_supertype
    choose I18n.t("supertypes.news.label")
    click_on "Continue"
  end

  def and_i_select_a_document_type
    choose @document_type.label
    click_on "Continue"
  end

  def and_i_fill_in_the_contents
    stub_any_publishing_api_put_content
    fill_in "summary", with: "A summary"
    click_on "Save"
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content("A summary")
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content("1st edition")
                .and have_content(I18n.t!("documents.history.entry_types.created"))
                .and have_content(I18n.t!("documents.history.entry_types.updated_content"))
  end
end
