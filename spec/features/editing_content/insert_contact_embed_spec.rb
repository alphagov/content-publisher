# frozen_string_literal: true

RSpec.feature "Insert contact embed", js: true do
  include AccessibleAutocompleteHelper

  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_contact
    and_i_select_a_contact
    then_i_see_the_contact_preview
    when_i_click_insert_contact
    then_i_see_the_snippet_is_inserted
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

  def and_i_click_to_insert_a_contact
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
    stub_publishing_api_get_editions([@contact], Contacts::EDITION_PARAMS)
    stub_publishing_api_put_content(@edition.content_id, {})
    find("markdown-toolbar details").click
    click_on "Contact"
  end

  def and_i_select_a_contact
    accessible_autocomplete_select "Contact",
                                   for_id: "contact-id",
                                   value: @contact["content_id"]
  end

  def then_i_see_the_contact_preview
    within(".gem-c-modal-dialogue .app-c-contact-preview") do
      expect(page).to have_content(@contact["title"])
    end
  end

  def when_i_click_insert_contact
    click_on "Insert contact"
  end

  def then_i_see_the_snippet_is_inserted
    snippet = I18n.t("contact_embed.new.contact_markdown", id: @contact["content_id"])
    expect(find("#body-field").value).to match snippet
  end
end
