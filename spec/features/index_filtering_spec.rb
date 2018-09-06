# frozen_string_literal: true

RSpec.feature "User filters documents" do
  scenario "User filters documents" do
    given_there_are_some_documents
    when_i_visit_the_index_page
    and_i_filter_by_title
    then_i_see_just_the_ones_that_match
    when_i_clear_the_filters
    then_i_see_all_the_documents
    when_i_filter_by_document_type
    then_i_see_just_the_ones_that_match
    when_i_filter_too_much
    then_i_see_there_are_no_results
  end

  def given_there_are_some_documents
    relevant_schema = build(:document_type_schema)
    @relevant_document = create(:document,
                                title: "Super relevant",
                                document_type: relevant_schema.id)

    irrelevant_schema = build(:document_type_schema)
    create(:document,
           title: "Totally irrelevant",
           document_type: irrelevant_schema.id)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def and_i_filter_by_title
    fill_in "title", with: "super"
    click_on "Filter"
  end

  def then_i_see_just_the_ones_that_match
    expect(page).to have_content("1 document")
    expect(page).to have_content(@relevant_document.title)
  end

  def when_i_clear_the_filters
    click_on "Clear filter"
  end

  def then_i_see_all_the_documents
    expect(page).to have_content("2 documents")
  end

  def when_i_filter_by_document_type
    select @relevant_document.document_type_schema.label, from: "document_type"
    click_on "Filter"
  end

  def when_i_filter_too_much
    fill_in "title", with: SecureRandom.uuid
    click_on "Filter"
  end

  def then_i_see_there_are_no_results
    expect(page).to have_content("0 documents")
  end
end
