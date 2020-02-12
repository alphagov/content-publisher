RSpec.describe "Insert video embed", js: true do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_video
    and_i_enter_and_embed_a_video
    then_i_see_the_snippet_is_inserted
  end

  def given_there_is_an_edition
    document_type = build(:document_type, :with_body)
    @edition = create(:edition, document_type: document_type)
  end

  def when_i_go_to_edit_the_edition
    visit content_path(@edition.document)
  end

  def and_i_click_to_insert_a_video
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Video"
    end
  end

  def and_i_enter_and_embed_a_video
    fill_in "title", with: "A title"
    fill_in "url", with: "https://www.youtube.com/watch?v=G8KpPw303PY"
    click_on "Embed video"
  end

  def then_i_see_the_snippet_is_inserted
    expect(page).not_to have_selector(".gem-c-modal-dialogue")
    snippet = "[A title](https://www.youtube.com/watch?v=G8KpPw303PY)"
    expect(find("#body-field").value).to include snippet
  end
end
