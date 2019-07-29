# frozen_string_literal: true

RSpec.feature "Insert contact without Javascript when the Publishing API is down" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_the_publishing_api_is_down
    and_i_go_to_add_a_contact
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

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_go_to_add_a_contact
    stub_publishing_api_put_content(@edition.content_id, {})
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content(I18n.t("contacts.index.api_down"))
  end
end
