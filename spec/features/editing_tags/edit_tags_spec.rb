RSpec.feature "Edit tags" do
  let(:initial_tag) { { "content_id" => SecureRandom.uuid, "internal_name" => "Initial tag" } }
  let(:tag_to_select_1) { { "content_id" => SecureRandom.uuid, "internal_name" => "Tag to select 1" } }
  let(:tag_to_select_2) { { "content_id" => SecureRandom.uuid, "internal_name" => "Tag to select 2" } }
  let(:single_tag_field) { DocumentType::PrimaryPublishingOrganisationField.new }
  let(:multi_tag_field) { DocumentType::WorldLocationsField.new }

  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_edit_tags
    then_i_see_the_current_selections
    when_i_edit_the_tags
    then_i_can_see_the_tags
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition
    document_type = build(:document_type, tags: [multi_tag_field, single_tag_field])

    tag_linkables = [initial_tag, tag_to_select_1, tag_to_select_2]
    stub_publishing_api_has_linkables(tag_linkables, document_type: multi_tag_field.document_type)
    stub_publishing_api_has_linkables(tag_linkables, document_type: single_tag_field.document_type)

    initial_tags = {
      multi_tag_field.id => [initial_tag["content_id"]],
      single_tag_field.id => [initial_tag["content_id"]],
    }

    @edition = create(:edition,
                      document_type: document_type,
                      tags: initial_tags)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_edit_tags
    click_on "Change Tags"
  end

  def then_i_see_the_current_selections
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    expect(page).to have_select("tags[#{multi_tag_field.id}][]", selected: "Initial tag")
    expect(page).to have_select("tags[#{single_tag_field.id}][]", selected: "Initial tag")
  end

  def when_i_edit_the_tags
    select "Tag to select 1", from: "tags[#{multi_tag_field.id}][]"
    select "Tag to select 2", from: "tags[#{multi_tag_field.id}][]"
    unselect "Initial tag", from: "tags[#{multi_tag_field.id}][]"
    select "Tag to select 1", from: "tags[#{single_tag_field.id}][]"
    click_on "Save"
  end

  def then_i_can_see_the_tags
    within("#tags") do
      expect(page).to have_content("Tag to select 1")
      expect(page).to have_content("Tag to select 2")
      expect(page).not_to have_content("Initial tag")
    end
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.updated_tags")
  end
end
