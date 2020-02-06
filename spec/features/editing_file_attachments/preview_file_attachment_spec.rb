# frozen_string_literal: true

RSpec.feature "Preview file attachment" do
  scenario do
    given_there_is_an_edition_with_attachments
    and_the_attachment_is_available
    when_i_preview_the_attachment
    then_i_should_see_the_attachment
  end

  def given_there_is_an_edition_with_attachments
    body_field = DocumentType::BodyField.new
    document_type = build(:document_type, contents: [body_field])
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    @asset = @attachment_revision.asset

    @edition = create(:edition,
                      document_type: document_type,
                      file_attachment_revisions: [@attachment_revision])
  end

  def and_the_attachment_is_available
    stub_asset_manager_has_an_asset(@asset.asset_manager_id, "state": "uploaded")
  end

  def when_i_preview_the_attachment
    visit content_path(@edition.document)
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Attachment"
    end

    click_on "Preview"
  end

  def then_i_should_see_the_attachment
    expect(current_url).to match(/#{@asset.file_url}\?token=.*/)
  end
end
