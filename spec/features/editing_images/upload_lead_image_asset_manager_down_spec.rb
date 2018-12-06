# frozen_string_literal: true

RSpec.feature "Upload a lead image when Asset Manager is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    and_asset_manager_is_down
    and_i_upload_an_image
    then_i_should_see_an_error
    and_the_image_does_not_exist
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    create(:document, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_asset_manager_is_down
    asset_manager_upload_failure
  end

  def and_i_upload_an_image
    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t!("document_images.index.flashes.api_error.title"))
  end

  def and_the_image_does_not_exist
    expect(page).to_not have_css("img[class='app-c-image-meta__image']")
    expect(Image.count).to eq(0)
  end
end
