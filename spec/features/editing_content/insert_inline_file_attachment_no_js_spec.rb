# frozen_string_literal: true

RSpec.feature "Insert inline file attachment without Javascript" do
  scenario do
    given_there_is_an_edition_with_file_attachments
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_file_attachment
    and_i_choose_one_of_the_file_attachments
    then_i_see_the_attachment_markdown_snippet
    and_i_see_the_attachment_link_markdown_snippet
  end

  def given_there_is_an_edition_with_file_attachments
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @file_attachment_revision = create(:file_attachment_revision,
                                       :on_asset_manager,
                                       filename: "foo.pdf")
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@file_attachment_revision])
  end

  def when_i_go_to_edit_the_edition
    visit edit_document_path(@edition.document)
  end

  def and_i_click_to_insert_a_file_attachment
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Attachment"
    end
  end

  def and_i_choose_one_of_the_file_attachments
    click_on "Insert attachment"
  end

  def then_i_see_the_attachment_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end

  def and_i_see_the_attachment_link_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_link_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end
end
