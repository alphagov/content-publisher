# frozen_string_literal: true

RSpec.feature "Create a document" do
  scenario do
    given_i_am_on_the_home_page
    when_i_click_to_create_a_document
    and_i_select_a_supertype
    and_i_select_a_document_type
    and_i_fill_in_the_contents
    then_i_see_the_document_summary
    and_the_preview_creation_was_successful
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def when_i_click_to_create_a_document
    @schema = build :document_type_schema
    click_on "New document"
  end

  def and_i_select_a_supertype
    choose SupertypeSchema.all.first.label
    click_on "Continue"
  end

  def and_i_select_a_document_type
    choose @schema.label
    click_on "Continue"
  end

  def and_i_fill_in_the_contents
    stub_any_publishing_api_put_content
    fill_in "document[title]", with: "A title"
    fill_in "document[summary]", with: "A summary"
    click_on "Save"
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content("A title")

    within find("#document-history") do
      expect(page).to have_content "1st edition"
      expect(page).to have_content I18n.t!("documents.history.entry_types.created")
      expect(page).to have_content I18n.t!("documents.history.entry_types.updated_content")
    end
  end

  def and_the_preview_creation_was_successful
    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)).to match a_hash_including(content_body)
    }).to have_been_requested
  end

  def content_body
    {
      "links" => {
        "organisations" => [User.first.organisation_content_id],
        "primary_publishing_organisation" => [User.first.organisation_content_id],
      },
      "title" => "A title",
      "document_type" => @schema.id,
      "description" => "A summary",
      "update_type" => "major",
      "change_note" => "First published.",
      "base_path" => "/a-title",
      "locale" => "en",
    }
  end
end
