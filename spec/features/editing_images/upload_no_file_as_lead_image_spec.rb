# frozen_string_literal: true

RSpec.feature "Upload no file as a lead image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    when_i_upload_no_file
    then_i_should_see_an_error
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    create(:document, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def when_i_upload_no_file
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t!("document_images.index.flashes.upload_requirements.no_file_selected"))
  end
end
