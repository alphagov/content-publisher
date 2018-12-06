# frozen_string_literal: true

RSpec.feature "User filters documents" do
  scenario do
    given_there_are_some_documents
    when_i_visit_the_index_page
    and_i_filter_by_title
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    then_i_see_all_the_documents

    when_i_filter_by_document_type
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_state
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_primary_organisation
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_organisation
    then_i_see_just_the_ones_that_match

    when_i_filter_too_much
    then_i_see_there_are_no_results
  end

  def given_there_are_some_documents
    create(:document, :published, title: "Totally irrelevant")
    @primary_organisation = { "content_id" => SecureRandom.uuid, "internal_name" => "Organisation 1" }
    @organisation = { "content_id" => SecureRandom.uuid, "internal_name" => "Organisation 2" }

    @relevant_document = create(:document,
                                :in_preview,
                                title: "Super relevant",
                                tags: {
                                  primary_publishing_organisation: [@primary_organisation["content_id"]],
                                  organisations: [@organisation["content_id"]],
                                })
  end

  def when_i_visit_the_index_page
    publishing_api_has_linkables([@primary_organisation, @organisation],
                                 document_type: "organisation")

    visit documents_path
  end

  def and_i_filter_by_title
    fill_in "title_or_url", with: "super"
    click_on "Filter"
  end

  def then_i_see_just_the_ones_that_match
    expect(page).to have_content("1 document")
    expect(page).to have_content(@relevant_document.title)
  end

  def when_i_clear_the_filters
    click_on "Clear all filters"
  end

  def then_i_see_all_the_documents
    expect(page).to have_content("2 documents")
  end

  def when_i_filter_by_document_type
    select @relevant_document.document_type_schema.label, from: "document_type"
    click_on "Filter"
  end

  def and_i_filter_by_state
    select I18n.t!("user_facing_states.draft.name"), from: "state"
    click_on "Filter"
  end

  def and_i_filter_by_primary_organisation
    select @primary_organisation["internal_name"], from: "organisation"
    click_on "Filter"
  end

  def and_i_filter_by_organisation
    select @organisation["internal_name"], from: "organisation"
    click_on "Filter"
  end

  def when_i_filter_too_much
    fill_in "title_or_url", with: SecureRandom.uuid
    click_on "Filter"
  end

  def then_i_see_there_are_no_results
    expect(page).to have_content("0 documents")
  end
end
