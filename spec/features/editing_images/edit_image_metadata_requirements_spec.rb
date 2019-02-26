# frozen_string_literal: true

RSpec.feature "Edit image metadata with requirements issues", js: true do
  scenario "lead image" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_with_bad_metadata
    then_i_see_an_error_to_fix_the_issues
  end

  scenario "inline image" do
    given_there_is_an_edition_with_images
    when_i_insert_an_inline_image
    and_i_edit_the_image_with_bad_metadata
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition_with_images
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_insert_an_inline_image
    visit edit_document_path(@edition.document)

    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def and_i_edit_the_image_with_bad_metadata
    stub_any_publishing_api_put_content
    stub_asset_manager_receives_an_asset
    stub_asset_manager_deletes_any_asset

    click_on "Edit image"
    click_on "Crop image"
    fill_in "image_revision[alt_text]", with: ""
    click_on "Save"
  end

  def then_i_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.alt_text.blank.form_message"))
  end
end
