# frozen_string_literal: true

RSpec.feature "Delete an image after publishing" do
  scenario "Delete an image after publishing" do
    given_there_is_a_document_with_images
    when_i_visit_the_document_images_page
    then_i_can_choose_to_delete_the_images
    when_i_publish_the_document_on_govuk
    then_i_cannot_delete_any_of_the_images
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    document = create(:document, document_type_id: document_type.id)
    create(:image, :in_preview, document: document)
    lead_image = create(:image, :in_preview, document: document)
    document.update(lead_image_id: lead_image.id)
  end

  def then_i_can_choose_to_delete_the_images
    expect(page).to have_content("Delete image")
    expect(page).to have_content("Delete lead image")
  end

  def when_i_publish_the_document_on_govuk
    Document.last.update!(has_live_version_on_govuk: true)
    visit document_images_path(Document.last)
  end

  def when_i_visit_the_document_images_page
    visit document_images_path(Document.last)
  end

  def then_i_cannot_delete_any_of_the_images
    expect(page).to_not have_content("Delete image")
    expect(page).to_not have_content("Delete lead image")
  end
end
