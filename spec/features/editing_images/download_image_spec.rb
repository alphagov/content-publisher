# frozen_string_literal: true

RSpec.feature "Download a image" do
  scenario do
    given_there_is_an_edition_with_images
    when_i_visit_the_image_index_page
    and_i_click_the_link_to_download_the_image
    then_the_image_should_have_been_downloaded
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_image_index_page
    visit images_path(@edition.document)
  end

  def and_i_click_the_link_to_download_the_image
    click_on("Download 960x640 image")
  end

  def then_the_image_should_have_been_downloaded
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"#{@image_revision.filename}\"; filename*=UTF-8\'\'#{@image_revision.filename}")
  end
end
