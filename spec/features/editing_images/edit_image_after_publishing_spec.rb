# frozen_string_literal: true

RSpec.feature "Edit an image after publishing" do
  scenario do
    given_there_is_a_document
    and_the_document_has_images
    when_i_visit_the_images_page
    then_i_can_edit_the_images
    when_i_publish_the_document
    then_i_cannot_edit_the_images
    when_i_add_some_more_images
    then_i_can_edit_the_new_image
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    @document = create(:document, :publishable, document_type_id: document_type.id)
  end

  def and_the_document_has_images
    create(:image, :in_preview, document: @document)
    image = create(:image, :in_preview, document: @document)
    @document.update!(lead_image_id: image.id)
  end

  def then_i_can_edit_the_images
    expect(page).to have_content("Delete image")
    expect(page).to have_content("Delete lead image")
    expect(page).to have_content("Edit crop")
    expect(page).to have_content("Edit details")
    expect(page).to have_content("Remove lead image")
  end

  def when_i_publish_the_document
    visit document_path(@document)
    click_on "Publish"
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    stub_publishing_api_publish(@document.content_id, update_type: nil, locale: @document.locale)
    @document.images.each { |image| asset_manager_update_asset(image.asset_manager_id) }
    click_on "Confirm publish"
  end

  def when_i_visit_the_images_page
    visit images_path(@document)
  end

  def then_i_cannot_edit_the_images
    visit images_path(@document)
    expect(page).to_not have_content("Delete image")
    expect(page).to_not have_content("Delete lead image")
    expect(page).to_not have_content("Edit crop")
    expect(page).to_not have_content("Edit details")
    expect(page).to have_content("Remove lead image")
  end

  def when_i_add_some_more_images
    create(:image, document: @document)
    image = create(:image, document: @document)
    @document.update!(lead_image_id: image.id)
  end

  def then_i_can_edit_the_new_image
    visit images_path(@document)
    then_i_can_edit_the_images
  end
end
