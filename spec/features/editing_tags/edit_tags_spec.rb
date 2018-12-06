# frozen_string_literal: true

RSpec.feature "Edit document tags" do
  let(:initial_tag) { { "content_id" => SecureRandom.uuid, "internal_name" => "Initial tag" } }
  let(:tag_to_select_1) { { "content_id" => SecureRandom.uuid, "internal_name" => "Tag to select 1" } }
  let(:tag_to_select_2) { { "content_id" => SecureRandom.uuid, "internal_name" => "Tag to select 2" } }

  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_edit_tags
    then_i_see_the_current_selections
    when_i_edit_the_tags
    then_i_can_see_the_tags
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    multi_tag_schema = build(:tag_schema, type: "multi_tag", id: "multi_tag_id")
    single_tag_schema = build(:tag_schema, type: "single_tag", id: "single_tag_id")
    document_type_schema = build(:document_type_schema, tags: [multi_tag_schema, single_tag_schema])

    tag_linkables = [initial_tag, tag_to_select_1, tag_to_select_2]
    publishing_api_has_linkables(tag_linkables, document_type: multi_tag_schema["document_type"])
    publishing_api_has_linkables(tag_linkables, document_type: single_tag_schema["document_type"])

    initial_tags = {
      multi_tag_schema["id"] => [initial_tag["content_id"]],
      single_tag_schema["id"] => [initial_tag["content_id"]],
    }

    @document = create(:document, document_type_id: document_type_schema.id, tags: initial_tags)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_edit_tags
    click_on "Change Tags"
  end

  def then_i_see_the_current_selections
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    expect(page).to have_select("tags[multi_tag_id][]", selected: "Initial tag")
    expect(page).to have_select("tags[single_tag_id][]", selected: "Initial tag")
  end

  def when_i_edit_the_tags
    select "Tag to select 1", from: "tags[multi_tag_id][]"
    select "Tag to select 2", from: "tags[multi_tag_id][]"
    unselect "Initial tag", from: "tags[multi_tag_id][]"
    select "Tag to select 1", from: "tags[single_tag_id][]"
    click_on "Save"
  end

  def then_i_can_see_the_tags
    within("#tags") do
      expect(page).to have_content("Tag to select 1")
      expect(page).to have_content("Tag to select 2")
      expect(page).not_to have_content("Initial tag")
    end

    within find(".app-timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.updated_tags")
    end
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["links"]).to include(edition_links)
    }).to have_been_requested
  end

  def edition_links
    {
      "multi_tag_id" => [tag_to_select_1["content_id"], tag_to_select_2["content_id"]],
      "single_tag_id" => [tag_to_select_1["content_id"]],
    }
  end
end
