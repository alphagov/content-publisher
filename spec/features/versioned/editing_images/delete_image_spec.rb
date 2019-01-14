# frozen_string_literal: true

RSpec.feature "Delete an image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    @image_revision = create(:versioned_image_revision, :on_asset_manager)
    @edition = create(:versioned_edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit versioned_images_path(@edition.document)
  end

  def and_i_delete_the_non_lead_image
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete image"
  end

  def then_i_see_the_image_is_gone
    expect(all("#image-#{@image_revision.image_id}").count).to be_zero
    expect(page).to have_content(I18n.t!("images.index.flashes.deleted", file: @image_revision.filename))

    click_on "Back"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_removed"))
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
  end
end
