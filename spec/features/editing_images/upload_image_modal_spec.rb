# frozen_string_literal: true

RSpec.feature "Upload image in a modal", js: true do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_an_image
    and_i_pick_and_upload_an_image
    and_i_crop_the_image
    then_i_see_the_uploaded_image
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @edition = create(:edition, document_type_id: document_type.id)
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

  def and_i_pick_and_upload_an_image
    @image_filename = "1000x1000.jpg"
    find('form input[type="file"]').set(Rails.root.join(file_fixture(@image_filename)))
    click_on "Upload"
  end

  def and_i_crop_the_image
    click_on "Crop image"
  end

  def then_i_see_the_uploaded_image
    expect(page).to have_selector(".app-c-image-meta")

    within("#image-#{Image.first.id}") do
      expect(find("img")["src"]).to include("1000x1000.jpg")
      expect(page).to have_link("Insert image markdown")
    end
  end
end
