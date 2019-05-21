# frozen_string_literal: true

RSpec.feature "Delete a file attachment", js: true do
  scenario do
    given_there_is_an_edition_with_attachments
    when_i_insert_an_attachment
    and_i_delete_the_attachment
    then_i_see_the_attachment_is_gone
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_attachments
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_insert_an_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_delete_the_attachment
    @put_content_request = stub_publishing_api_put_content(@edition.content_id, {})
    @delete_asset_request = stub_asset_manager_deletes_any_asset
    expect(page).to have_selector(".gem-c-attachment__metadata")
    click_on "Delete attachment"
  end

  def then_i_see_the_attachment_is_gone
    expect(all("#file-attachment-#{@attachment_revision.file_attachment_id}").count).to be_zero
    expect(page).to have_content(I18n.t!("file_attachments.index.flashes.deleted", file: @attachment_revision.filename))
  end

  def and_the_preview_creation_succeeded
    expect(@put_content_request).to have_been_requested
    expect(@delete_asset_request).to have_been_requested.at_least_once

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.file_attachment_deleted"))
  end
end
