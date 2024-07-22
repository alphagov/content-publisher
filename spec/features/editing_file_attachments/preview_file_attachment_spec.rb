RSpec.feature "Preview file attachment", :js do
  scenario do
    given_there_is_an_edition_with_attachments
    and_the_attachment_is_available
    when_i_preview_the_attachment
    then_i_should_see_the_attachment
  end

  def given_there_is_an_edition_with_attachments
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    @asset = @attachment_revision.asset

    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
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

    expect(page).to have_selector(".gem-c-attachment__metadata")
    @preview_window = window_opened_by { click_on @attachment_revision.title }
  end

  def then_i_should_see_the_attachment
    within_window @preview_window do
      expect(current_url).to match(/#{@asset.file_url}\?token=.*/)
    end
  end
end
