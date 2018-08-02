# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Add document associations", type: :feature do
  scenario "User adds associations to a document" do
    given_there_is_a_document_with_associations
    when_i_visit_the_document_page
    and_i_navigate_to_associations
    and_i_add_some_associations
    then_i_can_view_the_associations
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_associations
    @document = create(:document, :with_associations_in_schema)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_navigate_to_associations
    publishing_api_has_linkables(linkables, document_type: "topical_event")

    click_on "Edit associations"
  end

  def and_i_add_some_associations
    stub_any_publishing_api_put_content
    @request = stub_publishing_api_put_content(Document.last.content_id, {})

    select linkables[0]["title"], from: "associations[topical_events][]"
    select linkables[1]["title"], from: "associations[topical_events][]"
    click_on "Save"
  end

  def then_i_can_view_the_associations
    expect(page).to have_content linkables[0]["title"]
    expect(page).to have_content linkables[1]["title"]
    expect(page).not_to have_content linkables[2]["title"]
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content "Preview creation successful"

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["links"]).to eq(edition_links)
    }).to have_been_requested
  end

  def edition_links
    { "topical_events" => [linkables[0]["content_id"],
                           linkables[1]["content_id"]] }
  end

  def linkables
    @linkables ||= 3.times.map do |i|
      { "content_id" => SecureRandom.uuid, "title" => "Linkable #{i}" }
    end
  end
end
