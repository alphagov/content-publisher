# frozen_string_literal: true

RSpec.feature "Upload an inline image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    then_i_see_its_markdown_snippet
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_upload_a_new_image
    find('form input[type="file"]').set(Rails.root.join(file_fixture("Bad $ name.png")))
    click_on "Upload"
    visit images_path(@edition.document)
  end

  def then_i_see_its_markdown_snippet
    expect(page).to have_content(I18n.t("images.index.meta.inline_code.value", filename: "bad-name.png"))
  end
end
