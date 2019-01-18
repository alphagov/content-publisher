# frozen_string_literal: true

RSpec.feature "User filters documents when the Publishing API is down" do
  scenario do
    given_there_are_some_documents
    and_the_publishing_api_is_down
    when_i_visit_the_index_page
    then_i_cannot_filter_by_organisation
  end

  def given_there_are_some_documents
    create(:versioned_document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_index_page
    visit versioned_documents_path
  end

  def then_i_cannot_filter_by_organisation
    expect(all("#document-organisation-filter option").count).to eq 1
  end
end
