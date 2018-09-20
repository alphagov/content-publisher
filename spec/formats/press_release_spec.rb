# frozen_string_literal: true

RSpec.feature "Create a press release", format: true do
  scenario "User creates press release" do
    when_i_choose_this_document_type
    and_i_fill_in_the_form_fields
    and_i_add_some_tags
    then_i_can_publish_the_document
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("news").label
    click_on "Continue"
    choose DocumentTypeSchema.find("press_release").label
    click_on "Continue"
  end

  def and_i_fill_in_the_form_fields
    stub_any_publishing_api_put_content
    fill_in "document[title]", with: "A great title"
    fill_in "document[summary]", with: "A great summary"
    click_on "Save"
    WebMock.reset!
  end

  def and_i_add_some_tags
    stub_any_publishing_api_put_content
    expect(Document.last.document_type_schema.tags.count).to eq(6)
    publishing_api_has_linkables([linkable], document_type: "topical_event")
    publishing_api_has_linkables([linkable], document_type: "worldwide_organisation")
    publishing_api_has_linkables([linkable], document_type: "world_location")
    publishing_api_has_linkables([linkable], document_type: "organisation")
    publishing_api_has_linkables([linkable], document_type: "role_appointment")

    click_on "Change Tags"

    select linkable["internal_name"], from: "tags[topical_events][]"
    select linkable["internal_name"], from: "tags[worldwide_organisations][]"
    select linkable["internal_name"], from: "tags[world_locations][]"
    select linkable["internal_name"], from: "tags[organisations][]"
    select linkable["internal_name"], from: "tags[role_appointments][]"

    click_on "Save"
  end

  def then_i_can_publish_the_document
    expect(a_request(:put, /content/).with { |req|
             expect(req.body).to be_valid_against_schema("news_article")
             expect(JSON.parse(req.body)).to match a_hash_including(content_body)
           }).to have_been_requested
  end

  def content_body
    {
      "links" => {
        "topical_events" => [linkable["content_id"]],
        "worldwide_organisations" => [linkable["content_id"]],
        "world_locations" => [linkable["content_id"]],
        "organisations" => [linkable["content_id"]],
        "primary_publishing_organisation" => [linkable["content_id"]],
      },
      "title" => "A great title",
      "document_type" => "press_release",
      "description" => "A great summary",
    }
  end

  def linkable
    @linkable ||= { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable" }
  end
end
