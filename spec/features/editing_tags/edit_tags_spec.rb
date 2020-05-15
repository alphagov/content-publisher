RSpec.feature "Edit tags" do
  let(:initial_tag_content) { "Initial tag" }
  let(:initial_tag_content_id) { SecureRandom.uuid }
  let(:tag_to_select_1_content) { "Tag to select 1" }
  let(:tag_to_select_2_content) { "Tag to select 2" }
  let(:single_tag_field_id) { "primary_publishing_organisation" }
  let(:multi_tag_field_id) { "world_locations" }

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
    all_tags = DocumentType.all.flat_map(&:tags).uniq(&:class)
    tag_linkables = [
      { "content_id" => initial_tag_content_id, "internal_name" => initial_tag_content },
      { "content_id" => SecureRandom.uuid, "internal_name" => tag_to_select_1_content },
      { "content_id" => SecureRandom.uuid, "internal_name" => tag_to_select_2_content },
    ]
    all_tags.each do |tag|
      stub_publishing_api_has_linkables(tag_linkables, document_type: tag.id.singularize)
    end

    initial_tags = {
      multi_tag_field_id => [initial_tag_content_id],
      single_tag_field_id => [initial_tag_content_id],
    }

    @edition = create(
      :edition,
      document_type: build(:document_type, tags: all_tags),
      tags: initial_tags,
    )
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_edit_tags
    click_on "Change Tags"
  end

  def then_i_see_the_current_selections
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    expect(page).to have_select("#{multi_tag_field_id}[]", selected: initial_tag_content)
    expect(page).to have_select("#{single_tag_field_id}[]", selected: initial_tag_content)
  end

  def when_i_edit_the_tags
    select tag_to_select_1_content, from: "#{multi_tag_field_id}[]"
    select tag_to_select_2_content, from: "#{multi_tag_field_id}[]"
    unselect initial_tag_content, from: "#{multi_tag_field_id}[]"
    select tag_to_select_1_content, from: "#{single_tag_field_id}[]"
    click_on "Save"
  end

  def then_i_can_see_the_tags
    within("#tags") do
      expect(page).to have_content(tag_to_select_1_content)
      expect(page).to have_content(tag_to_select_2_content)
      expect(page).not_to have_content(initial_tag_content)
    end
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.updated_tags")
  end
end
