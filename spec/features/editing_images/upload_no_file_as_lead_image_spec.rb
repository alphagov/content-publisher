# frozen_string_literal: true

RSpec.feature "Upload no file as a lead image" do
  scenario "User uploads no file" do
    given_there_is_a_document
    when_i_visit_the_lead_images_page
    when_i_upload_no_file
    then_i_should_see_an_error
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def when_i_upload_no_file
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t("document_lead_image.index.no_file_selected"))
  end
end
