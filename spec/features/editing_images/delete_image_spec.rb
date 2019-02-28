# frozen_string_literal: true

RSpec.feature "Delete an image", js: true do
  scenario "lead image" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_the_preview_creation_succeeded
  end

  scenario "inline image" do
    given_there_is_an_edition_with_images
    when_i_insert_an_inline_image
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_images
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_insert_an_inline_image
    visit edit_document_path(@edition.document)

    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def and_i_delete_the_non_lead_image
    @put_content_request = stub_publishing_api_put_content(@edition.content_id, {})
    @delete_asset_request = stub_asset_manager_deletes_any_asset
    click_on "Delete image"
  end

  def then_i_see_the_image_is_gone
    expect(all("#image-#{@image_revision.image_id}").count).to be_zero
    expect(page).to have_content(I18n.t!("images.index.flashes.deleted", file: @image_revision.filename))
  end

  def and_the_preview_creation_succeeded
    expect(@put_content_request).to have_been_requested
    expect(@delete_asset_request).to have_been_requested.at_least_once

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_deleted"))
  end
end
