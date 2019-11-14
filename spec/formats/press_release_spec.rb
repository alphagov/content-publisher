# frozen_string_literal: true

RSpec.feature "Create a press release", format: true do
  include TopicsHelper

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_no_links
  end

  scenario do
    when_i_choose_this_document_type
    and_i_fill_in_the_form_fields
    and_i_add_some_tags
    then_i_can_publish_the_document
  end

  def when_i_choose_this_document_type
    visit root_path
    click_on "Create new document"
    choose Supertype.find("news").label
    click_on "Continue"
    choose DocumentType.find("press_release").label
    click_on "Continue"
  end

  def and_i_fill_in_the_form_fields
    fill_in "revision[title]", with: "A great title"
    fill_in "revision[summary]", with: "A great summary"

    document = Document.first
    base_path = document.document_type.path_prefix + "/a-great-title"
    stub_publishing_api_has_lookups(base_path => document.content_id)

    click_on "Save"
    reset_executed_requests!
  end

  def and_i_add_some_tags
    stub_publishing_api_has_links(role_appointment_links)

    expect(Document.last.document_type.tags.count).to eq(5)
    stub_publishing_api_has_linkables([linkable], document_type: "topical_event")
    stub_publishing_api_has_linkables([linkable], document_type: "world_location")
    stub_publishing_api_has_linkables([linkable], document_type: "organisation")
    stub_publishing_api_has_linkables([linkable], document_type: "role_appointment")

    click_on "Change Tags"

    select linkable["internal_name"], from: "tags[topical_events][]"
    select linkable["internal_name"], from: "tags[world_locations][]"
    select linkable["internal_name"], from: "tags[primary_publishing_organisation][]"
    select linkable["internal_name"], from: "tags[organisations][]"
    select linkable["internal_name"], from: "tags[role_appointments][]"

    click_on "Save"
  end

  def then_i_can_publish_the_document
    expect(a_request(:put, /content/).with { |req|
             expect(req.body).to be_valid_against_publisher_schema("news_article")
             expect(JSON.parse(req.body)).to match a_hash_including(content_body)
           }).to have_been_requested
  end

  def content_body
    {
      "links" => {
        "topical_events" => [linkable["content_id"]],
        "world_locations" => [linkable["content_id"]],
        "organisations" => [linkable["content_id"]],
        "primary_publishing_organisation" => [linkable["content_id"]],
        "roles" => role_appointment_links["links"]["role"],
        "people" => role_appointment_links["links"]["person"],
      },
      "title" => "A great title",
      "document_type" => "press_release",
      "description" => "A great summary",
    }
  end

  def role_appointment_links
    @role_appointment_links ||= {
      "content_id" => linkable["content_id"],
      "links" => {
        "person" => [SecureRandom.uuid],
        "role" => [SecureRandom.uuid],
      },
    }
  end

  def linkable
    @linkable ||= { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable" }
  end
end
