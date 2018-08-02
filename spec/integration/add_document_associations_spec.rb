# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Add document associations", type: :feature do
  scenario "User adds associations to a document" do
    given_there_is_a_document_with_associations
    when_i_visit_the_document_page
    and_i_navigate_to_associations
    and_i_add_some_associations
    then_i_can_view_the_associations
  end

  def given_there_is_a_document_with_associations
    @document = create :document, document_type: "press_release"
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_navigate_to_associations
    publishing_api_has_linkables(linkables, document_type: "topical_event")

    click_on "Document associations"
  end

  def and_i_add_some_associations
    stub_any_publishing_api_put_content

    select "National Apprenticeship Week 2017", from: "associations[topical_event][]"
    select "G8 Dementia Summit", from: "associations[topical_event][]"
    click_on "Save"
  end

  def then_i_can_view_the_associations
    # @TODO these shouldn't be ids when feature is complete
    expect(page).to have_content "National Apprenticeship Week 2017"
    expect(page).not_to have_content "Autumn Statement 2016"
    expect(page).to have_content "G8 Dementia Summit"
  end

  def linkables
    [
      {
        "content_id" => "2a8ae727-e3bb-4b18-bce7-a19dc01ae5af",
        "title" => "National Apprenticeship Week 2017"
      },
      {
        "content_id" => "bbcb323e-242d-4012-96ca-be451d84587c",
        "title" => "Autumn Statement 2016"
      },
      {
        "content_id" => "97d2e88e-81c2-4da1-8002-69bc8f1afffa",
        "title" => "G8 Dementia Summit"
      }
    ].map do |item|
      item.merge(
        "publication_state" => "published",
        "base_path" => "/government/topical-events/#{item['title'].parameterize}",
        "internal_name" => item["title"],
      )
    end
  end
end
