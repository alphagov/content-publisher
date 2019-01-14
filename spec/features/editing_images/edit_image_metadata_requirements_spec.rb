# frozen_string_literal: true

RSpec.feature "Edit image metadata with requirements issues" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_with_bad_metadata
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_edit_the_image_with_bad_metadata
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Edit details"
    fill_in "image_revision[alt_text]", with: ""
    click_on "Save details"
  end

  def then_i_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.alt_text.blank.form_message"))
  end
end
