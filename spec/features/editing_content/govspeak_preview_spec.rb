# frozen_string_literal: true

RSpec.feature "Shows a preview of Govspeak", js: true do
  scenario do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_enter_some_govspeak
    and_i_view_the_govspeak_preview
    then_i_see_the_rendered_govspeak
  end

  def given_there_is_a_document
    body_field_schema = build(:field_schema, id: "body", type: "govspeak")
    document_type_schema = build(:document_type_schema, contents: [body_field_schema])
    @document = create(:document, document_type_id: document_type_schema.id)
  end

  def when_i_go_to_edit_the_document
    visit document_path(@document)
    click_on "Change Content"
  end

  def and_i_enter_some_govspeak
    fill_in "document[contents][body]", with: "$C “contact” $C"
  end

  def and_i_view_the_govspeak_preview
    click_on "Preview"
  end

  def then_i_see_the_rendered_govspeak
    expect(find(".app-c-markdown-editor__govspeak--rendered")["innerHTML"])
      .to include('<div class="contact">')
  end
end
