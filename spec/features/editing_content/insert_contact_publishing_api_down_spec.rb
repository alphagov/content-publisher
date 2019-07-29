# frozen_string_literal: true

RSpec.feature "Insert contact when the Publishing API down" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_add_a_contact_with_the_publishing_api_down
    then_i_should_see_an_error_message
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

  def and_i_go_to_add_a_contact_with_the_publishing_api_down
    publishing_api_isnt_available
    # Add contact will submit the form and update the content before redirecting
    # thus we want the put content API call to succeed before contacts being
    # unavailable
    stub_publishing_api_put_content(@edition.content_id, {})
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content(I18n.t("contacts.index.api_down"))
  end
end
