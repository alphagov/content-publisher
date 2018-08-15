# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Setting a primary publishing organisation" do
  scenario "User creates a new document" do
    given_a_user_belonging_to_an_org_exists
    when_they_create_a_document
    and_save_a_draft
    then_the_primary_publishing_org_should_default_to_their_own
  end

  def given_a_user_belonging_to_an_org_exists
    User.first.update(organisation_content_id: "some-org")
  end

  def when_they_create_a_document
    association_schema = build(:association_schema, type: "single_association", document_type: "organisation", id: "primary_publishing_organisation")
    build(:document_type_schema, supertype: "news", label: "Test schema", associations: [association_schema])
    visit "/"
    click_on "New document"

    choose "News"
    click_on "Continue"

    choose "Test schema"
    click_on "Continue"
  end

  def and_save_a_draft
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    publishing_api_has_linkables([{ "internal_name" => "My cool org", "content_id" => "some-org" }], document_type: "organisation")
    fill_in "document[title]", with: "A great title"
    click_on "Save"
  end

  def then_the_primary_publishing_org_should_default_to_their_own
    expect(Document.last.associations["primary_publishing_organisation"]).to eq(["some-org"])

    expect(@request).to have_been_requested
    expect(a_request(:put, /content/).with { |req|
             expect(JSON.parse(req.body)["links"]).to eq("primary_publishing_organisation" => ["some-org"],
                                                         "original_primary_publishing_organisation" => ["some-org"])
           }).to have_been_requested
  end
end
