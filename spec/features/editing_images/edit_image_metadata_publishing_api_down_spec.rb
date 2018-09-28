# frozen_string_literal: true

RSpec.feature "Edit image metadata when the Publishing API is down" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_the_publishing_api_is_down
    and_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_the_preview_creation_failed
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, document: document)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_edit_the_image_metadata
    click_on "Edit details"
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "A caption"
    fill_in "credit", with: "A credit"
    click_on "Save details"
  end

  def then_i_see_the_image_is_updated
    expect(page).to have_content("Some alt text")
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_images.index.flashes.api_error.title"))
  end
end
