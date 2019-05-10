# frozen_string_literal: true

RSpec.feature "Upload file attachment" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_insert_an_attachment
    and_i_upload_a_file_attachment
    then_i_can_see_the_attachment_markdown
    and_i_can_see_previews_of_the_attachment
    and_the_attachment_has_been_uploaded_successfully
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_go_to_edit_the_edition
    visit document_path(@edition.document)
    click_on "Change Content"
  end

  def and_i_go_to_insert_an_attachment
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_upload_a_file_attachment
    @asset_manager_request = stub_asset_manager_receives_an_asset(filename: @attachment_filename)
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})

    @attachment_filename = "13kb-1-page-attachment.pdf"
    @title = "A title"

    find('form input[type="file"]').set(Rails.root.join(file_fixture(@attachment_filename)))
    fill_in "title", with: @title
    click_on "Upload"
  end

  def then_i_can_see_the_attachment_markdown
    expect(page).to have_content("[Attachment: #{@attachment_filename}]")
    expect(page).to have_content("[AttachmentLink: #{@attachment_filename}]")
  end

  def and_i_can_see_previews_of_the_attachment
    metadata = "PDF, 13 KB, 1 page"

    within(".gem-c-attachment") do
      expect(page).to have_content(@title)
      expect(page).to have_content(metadata)
    end

    within(".gem-c-attachment-link") do
      expect(page).to have_content(@title)
      expect(page).to have_content(metadata)
    end
  end

  def and_the_attachment_has_been_uploaded_successfully
    expect(@publishing_api_request).to have_been_requested
    expect(@asset_manager_request).to have_been_requested.at_least_once

    visit document_path(@edition.document)
    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.file_attachment_uploaded")
    end
  end
end
