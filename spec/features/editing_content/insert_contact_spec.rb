# frozen_string_literal: true

RSpec.feature "Insert contact", js: true do
  include AccessibleAutocompleteHelper

  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_add_a_contact
    when_i_select_a_contact
    then_i_can_see_the_contact_in_the_body
  end

  let(:organisation) { { "content_id" => SecureRandom.uuid, "internal_name" => "Organisation" } }
  let(:contact) do
    {
      "content_id" => SecureRandom.uuid,
      "title" => "Contact",
      "links" => { "organisations" => [organisation["content_id"]] },
    }
  end

  before do
    stub_publishing_api_has_linkables([organisation], document_type: "organisation")
    stub_publishing_api_get_editions([contact], ContactsService::EDITION_PARAMS)
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
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def when_i_select_a_contact
    accessible_autocomplete_select "Contact",
                                   for_id: "contact-id",
                                   value: contact["content_id"]
    click_on "Insert contact"
  end

  def then_i_can_see_the_contact_in_the_body
    expect(find_field("revision[contents][body]").value)
      .to match(/\[Contact:#{contact['content_id']}\]/)
  end
end
