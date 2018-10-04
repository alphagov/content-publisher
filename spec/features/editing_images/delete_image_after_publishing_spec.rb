# frozen_string_literal: true

RSpec.feature "Delete an image after publishing" do
  scenario "Delete an image after publishing" do
    given_there_is_a_document_with_images
    and_the_document_is_live_on_govuk
    when_i_visit_the_lead_images_page
    then_i_cannot_delete_any_of_the_images
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, :in_asset_manager, document: document)
  end

  def and_the_document_is_live_on_govuk
    Document.last.update(has_live_version_on_govuk: true)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def then_i_cannot_delete_any_of_the_images
    expect(page).to_not have_content("Delete image")
  end
end
