# frozen_string_literal: true

RSpec.feature "Index filtering" do
  scenario do
    given_there_are_some_editions
    when_i_visit_the_index_page
    then_i_only_see_my_organisations_editions

    when_i_clear_the_filters
    then_i_see_all_editions

    when_i_clear_the_filters
    and_i_filter_by_title
    then_i_see_just_the_ones_that_match

    when_i_filter_by_document_type
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_state
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_organisation
    then_i_see_just_the_ones_that_match

    when_i_filter_too_much
    then_i_see_there_are_no_results
  end

  def given_there_are_some_editions
    @primary_organisation = { "content_id" => current_user.organisation_content_id,
                              "internal_name" => "Organisation 1" }
    @other_organisation = { "content_id" => SecureRandom.uuid,
                            "internal_name" => "Organisation 2" }

    @relevant_edition = create(:edition,
                               title: "Super relevant",
                               tags: {
                                 primary_publishing_organisation: [@primary_organisation["content_id"]],
                                 organisations: [
                                   @primary_organisation["content_id"],
                                   @other_organisation["content_id"],
                                 ],
                               })
    create(:edition,
           :published,
           title: "Irrelevant but my organistion",
           tags: {
             primary_publishing_organisation: [@primary_organisation["content_id"]],
             organisations: [@primary_organisation["content_id"]],
           })

    create(:edition, :published, title: "Not even my organisation")
  end

  def when_i_visit_the_index_page
    stub_publishing_api_has_linkables(
      [@primary_organisation, @other_organisation],
      document_type: "organisation",
    )

    visit documents_path
  end

  def and_i_filter_by_title
    fill_in "title_or_url", with: "super"
    click_on "Filter"
  end

  def then_i_see_just_the_ones_that_match
    expect(page).to have_content("1 document")
    expect(page).to have_content(@relevant_edition.title)
  end

  def when_i_clear_the_filters
    click_on "Clear all filters"
  end

  def then_i_only_see_my_organisations_editions
    expect(page).to have_content("2 documents")
  end

  def when_i_filter_by_all_organisations
    select "", from: "organisation"
    click_on "Filter"
  end

  def then_i_see_all_editions
    expect(page).to have_content("3 documents")
  end

  def when_i_filter_by_document_type
    select @relevant_edition.document_type.label, from: "document_type"
    click_on "Filter"
  end

  def and_i_filter_by_state
    select I18n.t!("user_facing_states.draft.name"), from: "status"
    click_on "Filter"
  end

  def and_i_filter_by_organisation
    select @other_organisation["internal_name"], from: "organisation"
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
