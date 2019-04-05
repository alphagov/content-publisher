# frozen_string_literal: true

RSpec.describe "Insert video embed", js: true do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_video
    and_i_embed_an_invalid_video
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_go_to_edit_the_edition
    visit edit_document_path(@edition.document)
  end

  def and_i_click_to_insert_a_video
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Video"
    end
  end

  def and_i_embed_an_invalid_video
    click_on "Embed video"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.video_embed_title.blank.form_message"))
    end
  end
end
