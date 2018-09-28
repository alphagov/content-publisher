# frozen_string_literal: true

RSpec.feature "Delete a lead image with Publishing API down" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_the_publishing_api_is_down
    and_i_delete_the_lead_image
    then_i_see_the_image_still_exists
    and_the_preview_creation_failed
    and_the_document_has_no_lead_image
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, :in_asset_manager, document: document)
    document.update(lead_image: @image)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_delete_the_lead_image
    click_on "Delete lead image"
  end

  def then_i_see_the_image_still_exists
    expect(all("#image-#{@image.id}").count).to eq 1
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_images.index.flashes.api_error.title"))
  end

  def and_the_document_has_no_lead_image
    click_on "Back"
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
  end
end
