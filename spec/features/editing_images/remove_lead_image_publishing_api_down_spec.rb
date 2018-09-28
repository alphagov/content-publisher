# frozen_string_literal: true

RSpec.feature "Remove a lead image when Publishing API is down" do
  scenario do
    given_there_is_a_document_with_a_lead_image
    when_i_visit_the_lead_images_page
    and_the_publishing_api_is_down
    and_i_remove_the_lead_image
    then_i_see_the_document_has_no_lead_image
  end

  def given_there_is_a_document_with_a_lead_image
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, document: document)
    document.update(lead_image: @image)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_remove_the_lead_image
    click_on "Remove"
  end

  def then_i_see_the_document_has_no_lead_image
    within("#image-#{@image.id}") do
      expect(page).to_not have_content(I18n.t("document_lead_image.index.lead_image"))
    end
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.api_error.title"))
  end
end
