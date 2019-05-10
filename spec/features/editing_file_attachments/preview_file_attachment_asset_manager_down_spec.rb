# frozen_string_literal: true

RSpec.feature "Preview file attachment when Asset Manager is down" do
  scenario do
    given_there_is_an_edition_with_attachments
    and_asset_manager_is_down
    when_i_preview_the_attachment
    then_i_should_see_a_pending_page
  end

  def given_there_is_an_edition_with_attachments
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@attachment_revision])
  end

  def and_asset_manager_is_down
    stub_asset_manager_isnt_available
  end

  def when_i_preview_the_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
    click_on "Preview"
  end

  def then_i_should_see_a_pending_page
    expect(page).to have_content I18n.t!("file_attachments.preview_pending.title")
  end
end
