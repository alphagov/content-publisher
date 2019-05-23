# frozen_string_literal: true

RSpec.feature "Insert inline image without Javascript" do
  scenario do
    given_there_is_an_edition_with_images
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_an_image
    then_i_see_the_image_markdown_snippet
  end

  def given_there_is_an_edition_with_images
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             filename: "foo.jpg")
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_go_to_edit_the_edition
    visit edit_document_path(@edition.document)
  end

  def and_i_click_to_insert_an_image
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def then_i_see_the_image_markdown_snippet
    snippet = I18n.t("images.index.meta.inline_code.value", filename: @image_revision.filename)
    expect(page).to have_content(snippet)
  end
end
