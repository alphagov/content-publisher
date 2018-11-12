# frozen_string_literal: true

RSpec.feature "Choose a lead image when the Publishing API is down" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    and_the_publishing_api_is_down
    and_i_choose_one_of_the_images
    then_i_see_the_document_has_a_lead_image
    and_the_preview_creation_failed
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, :in_asset_manager, document: document)
  end

  def when_i_visit_the_summary_page
    visit document_path(Document.last)
  end

  def and_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_choose_one_of_the_images
    within("#image-#{@image.id}") do
      click_on "Select as lead image"
    end
  end

  def then_i_see_the_document_has_a_lead_image
    within("#image-#{@image.id}") do
      expect(page).to have_content("Remove lead image")
    end
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t!("document_images.index.flashes.api_error.title"))
  end
end
