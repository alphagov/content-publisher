# frozen_string_literal: true

RSpec.feature "Delete an image with Asset Manager down" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_asset_manager_is_down
    and_i_delete_the_non_lead_image
    then_i_see_the_image_still_exists
    and_the_api_operation_failed
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, :in_asset_manager, document: document)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_asset_manager_is_down
    asset_manager_delete_asset_failure(@image.asset_manager_id)
  end

  def and_i_delete_the_non_lead_image
    stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Delete image"
  end

  def then_i_see_the_image_still_exists
    expect(all("#image-#{@image.id}").count).to eq 1
  end

  def and_the_api_operation_failed
    expect(page).to have_content(I18n.t("document_images.index.flashes.api_error.title"))
  end
end
