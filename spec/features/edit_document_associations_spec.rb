# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Edit document associations" do
  let(:initial_association) { { "content_id" => SecureRandom.uuid, "internal_name" => "Initial association" } }
  let(:association_to_select_1) { { "content_id" => SecureRandom.uuid, "internal_name" => "Association to select 1" } }
  let(:association_to_select_2) { { "content_id" => SecureRandom.uuid, "internal_name" => "Association to select 2" } }

  scenario "User edits associations to a document" do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_edit_associations
    then_i_can_see_the_current_selections
    when_i_edit_the_associations
    then_i_can_view_the_associations
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    association_schema = build(:association_schema, type: "multi_association", id: "association_id")
    document_type_schema = build(:document_type_schema, associations: [association_schema])
    multi_association_linkables = [initial_association, association_to_select_1, association_to_select_2]
    publishing_api_has_linkables(multi_association_linkables, document_type: association_schema["document_type"])
    initial_associations = { association_schema["id"] => [initial_association["content_id"]] }
    @document = create(:document, document_type: document_type_schema.id, associations: initial_associations)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_edit_associations
    click_on I18n.t("documents.show.actions.edit_associations")
  end

  def then_i_can_see_the_current_selections
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    expect(page).to have_select("associations[association_id][]",
                                 selected: "Initial association")
  end

  def when_i_edit_the_associations
    select "Association to select 1", from: "associations[association_id][]"
    select "Association to select 2", from: "associations[association_id][]"
    unselect "Initial association", from: "associations[association_id][]"

    click_on I18n.t("document_associations.edit.actions.save")
  end

  def then_i_can_view_the_associations
    expect(page).to have_content("Association to select 1")
    expect(page).to have_content("Association to select 2")
    expect(page).not_to have_content("Initial association")
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.draft_success"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["links"]).to eq(edition_links)
    }).to have_been_requested
  end

  def edition_links
    {
      "association_id" => [association_to_select_1["content_id"], association_to_select_2["content_id"]]
    }
  end
end
