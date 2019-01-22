# frozen_string_literal: true

RSpec.feature "Index organisation filtering when the Publishing API is down" do
  scenario do
    given_the_publishing_api_is_down
    when_i_visit_the_index_page
    then_i_cannot_filter_by_organisation
  end

  def given_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_cannot_filter_by_organisation
    expect(all("#document-organisation-filter option").count).to eq 1
  end
end
