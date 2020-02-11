RSpec.describe "Insert contact embed" do
  include AccessibleAutocompleteHelper

  it "with javascript", js: true do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_contact
    and_i_select_a_contact_from_the_autcomplete
    then_i_see_the_contact_preview
    when_i_click_insert_contact
    then_i_see_the_snippet_is_inserted
  end

  it "without javascript" do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_contact
    and_i_select_a_contact_without_javascript
    then_i_see_the_contact_markdown_snippet
    and_i_see_a_preview_of_the_contact
  end

  def given_there_is_an_edition
    document_type = build(:document_type, :with_body)
    @edition = create(:edition, document_type: document_type)
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

  def and_i_select_a_contact_from_the_autcomplete
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
    expect(page).not_to have_selector(".gem-c-modal-dialogue") # wait for modal to close
    snippet = I18n.t!("contact_embed.new.contact_markdown", id: @contact["content_id"])
    expect(find("#body-field").value).to include snippet
  end

  def and_i_select_a_contact_without_javascript
    select "Contact", from: "contact-id"
    click_on "Show markdown code"
  end

  def then_i_see_the_contact_markdown_snippet
    snippet = I18n.t!("contact_embed.new.contact_markdown", id: @contact["content_id"])
    expect(page).to have_content(snippet)
  end

  def and_i_see_a_preview_of_the_contact
    within(".app-c-contact-preview") do
      expect(page).to have_content(@contact["title"])
    end
  end
end
