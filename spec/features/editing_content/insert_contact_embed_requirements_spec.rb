# frozen_string_literal: true

RSpec.feature "Insert contact embed with requirements issues", js: true do
  include AccessibleAutocompleteHelper

  scenario do
    given_there_is_an_edition
    when_i_click_to_insert_a_contact
    and_i_insert_without_a_selection
    then_i_see_an_error_to_fix_the_issue
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_click_to_insert_a_contact
    stub_publishing_api_get_editions([], Contacts::EDITION_PARAMS)
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def and_i_insert_without_a_selection
    click_on "Insert contact"
  end

  def then_i_see_an_error_to_fix_the_issue
    expect(page).to have_content(I18n.t!("requirements.contact_embed.blank.form_message"))
  end
end
