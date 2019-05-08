# frozen_string_literal: true

RSpec.feature "Preview file attachment", js: true do
  scenario do
    given_there_is_an_edition_with_attachments
    and_the_attachment_is_available
    when_i_preview_the_attachment
    then_i_should_see_the_attachment
  end

  def given_there_is_an_edition_with_attachments
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    @asset = @attachment_revision.asset("file")

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@attachment_revision])
  end

  def and_the_attachment_is_available
    stub_asset_manager_has_an_asset(@asset.asset_manager_id, "state": "uploaded")
  end

  def when_i_preview_the_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    @new_window = window_opened_by { click_on "Attachment" }

    within_window(@new_window) do
      @preview_window = window_opened_by { click_on "Preview" }
    end
  end

  def then_i_should_see_the_attachment
    within_window @preview_window do
      expect(current_url).to eq @asset.file_url
    end
  end
end
