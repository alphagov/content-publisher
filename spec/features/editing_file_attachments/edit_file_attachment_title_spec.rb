# frozen_string_literal: true

RSpec.feature "Edit a file attachment title" do
  scenario do
    given_there_is_an_edition_with_attachments
    when_i_click_to_insert_an_attachment
    and_i_click_on_edit_file
    then_i_see_the_current_attachment_title
  end

  def given_there_is_an_edition_with_attachments
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_click_to_insert_an_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_click_on_edit_file
    click_on "Edit file"
  end

  def then_i_see_the_current_attachment_title
    expect(page).to have_field("Edit title", with: @attachment_revision.title)
  end
end
