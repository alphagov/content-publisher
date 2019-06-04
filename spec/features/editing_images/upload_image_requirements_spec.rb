# frozen_string_literal: true

RSpec.feature "Upload an image with requirements issues", js: true do
  scenario "lead image" do
    given_there_is_an_edition
    when_i_visit_the_images_page
    and_i_upload_an_invalid_image
    then_i_should_see_an_error
  end

  scenario "inline image" do
    given_there_is_an_edition
    when_i_insert_an_inline_image
    and_i_upload_an_invalid_image
    then_i_should_see_an_error
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit document_path(@edition.document)
    click_on "Edit Lead image"
  end

  def when_i_insert_an_inline_image
    visit edit_document_path(@edition.document)

    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def and_i_upload_an_invalid_image
    find('form input[type="file"]').set(Rails.root.join(file_fixture("text-file.txt")))
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t!("requirements.image_upload.unsupported_type.form_message"))
  end
end
