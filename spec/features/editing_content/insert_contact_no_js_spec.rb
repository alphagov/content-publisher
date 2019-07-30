# frozen_string_literal: true

RSpec.feature "Insert contact without Javascript" do
  include AccessibleAutocompleteHelper

  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_add_a_contact
    when_i_select_a_contact
    then_i_see_the_contact_markdown_snippet
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

  def and_i_go_to_add_a_contact
    organisation = {
      "content_id" => SecureRandom.uuid,
      "internal_name" => "Organisation",
    }
    @contact = {
      "content_id" => SecureRandom.uuid,
      "title" => "Contact",
      "links" => { "organisations" => [organisation["content_id"]] },
    }
    stub_publishing_api_has_linkables([organisation], document_type: "organisation")
    stub_publishing_api_get_editions([@contact], ContactsService::EDITION_PARAMS)
    stub_publishing_api_put_content(@edition.content_id, {})
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def when_i_select_a_contact
    select "Contact", from: "contact-id"
    click_on "Show markdown code"
  end

  def then_i_see_the_contact_markdown_snippet
    snippet = I18n.t("contacts.index.contact_markdown", id: @contact["content_id"])
    expect(page).to have_content(snippet)
  end
end
