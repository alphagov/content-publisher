# frozen_string_literal: true

RSpec.feature "Shows a preview of Govspeak", js: true do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_enter_some_govspeak
    and_i_view_the_govspeak_preview
    then_i_see_the_rendered_govspeak
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_go_to_edit_the_edition
    visit document_path(@edition.document)
    click_on "Edit Content"
  end

  def and_i_enter_some_govspeak
    fill_in "revision[contents][body]", with: "$C “contact” $C"
  end

  def and_i_view_the_govspeak_preview
    click_on "Preview"
  end

  def then_i_see_the_rendered_govspeak
    expect(find(".app-c-markdown-editor__govspeak--rendered")["innerHTML"])
      .to include('<div class="contact">')
  end
end
