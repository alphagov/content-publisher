# frozen_string_literal: true

RSpec.feature "Insert contact" do
  scenario do
    given_there_is_a_document
    when_i_go_to_edit_the_document
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
    publishing_api_has_linkables([organisation], document_type: "organisation")
    publishing_api_get_editions([contact], ContactsService::EDITION_PARAMS)
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

  def and_i_go_to_add_a_contact
    @request = stub_publishing_api_put_content(@document.content_id, {})
    click_on "Add contact"
  end

  def when_i_select_a_contact
    select "Contact - Organisation", from: "contact_id"
    click_on "Insert contact"
  end

  def then_i_can_see_the_contact_in_the_body
    expect(find_field("document[contents][body]").value)
      .to match(/\[Contact:#{contact['content_id']}\]/)
  end
end
