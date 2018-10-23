# frozen_string_literal: true

RSpec.feature "Image drafting requirements" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    and_the_image_has_no_alt_text
    then_i_see_the_alt_text_is_needed

    when_i_enter_too_much_alt_text
    then_i_see_the_alt_text_is_too_long

    when_i_enter_too_much_caption_text
    then_i_see_the_caption_is_too_long
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, document: document)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_i_edit_the_image_metadata
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Edit details"
  end

  def and_the_image_has_no_alt_text
    fill_in "alt_text", with: ""
    click_on "Save details"
  end

  def then_i_see_the_alt_text_is_needed
    expect(page).to have_content(I18n.t("document_images.edit.flashes.drafting_requirements.alt_text_presence"))
  end

  def when_i_enter_too_much_alt_text
    @alt_text = "a" * (ImageDraftingRequirements::ALT_TEXT_MAX_LENGTH + 1)
    fill_in "alt_text", with: @alt_text
    click_on "Save details"
  end

  def then_i_see_the_alt_text_is_too_long
    expect(find_field("alt_text").value).to eq(@alt_text)

    expect(page).to have_content(I18n.t("document_images.edit.flashes.drafting_requirements.alt_text_max_length",
                                        max_length: ImageDraftingRequirements::ALT_TEXT_MAX_LENGTH))
  end

  def when_i_enter_too_much_caption_text
    @caption = "a" * (ImageDraftingRequirements::CAPTION_MAX_LENGTH + 1)
    fill_in "caption", with: @caption
    click_on "Save details"
  end

  def then_i_see_the_caption_is_too_long
    expect(find_field("caption").value).to eq(@caption)

    expect(page).to have_content(I18n.t("document_images.edit.flashes.drafting_requirements.caption_max_length",
                                        max_length: ImageDraftingRequirements::CAPTION_MAX_LENGTH))
  end
end
