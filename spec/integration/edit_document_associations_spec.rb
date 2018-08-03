# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit document associations", type: :feature do
  DocumentTypeSchema.all.each do |schema|
    scenario "User edits associations to a document" do
      @schema = schema

      given_there_is_a_document_with_associations
      when_i_visit_the_document_page
      and_i_click_on_edit_associations
      and_i_edit_the_associations
      then_i_can_view_the_associations
      and_the_preview_creation_succeeded
    end

    def given_there_is_a_document_with_associations
      publishing_api_has_linkables(linkables, document_type: "topical_event")
      publishing_api_has_linkables(linkables, document_type: "world_location")

      @document = create(:document, document_type: @schema.id,
                         associations: { topical_events: [linkables[2]["content_id"]],
                                         world_locations: [linkables[2]["content_id"]] })

      @associations = @document.document_type_schema.associations
    end

    def when_i_visit_the_document_page
      visit document_path(@document)
    end

    def and_i_click_on_edit_associations
      click_on "Edit associations"
    end

    def and_i_edit_the_associations
      stub_any_publishing_api_put_content
      @request = stub_publishing_api_put_content(Document.last.content_id, {})

      @associations.each do |association|
        select linkables[0]["internal_name"], from: "associations[#{association.id}][]"
        select linkables[1]["internal_name"], from: "associations[#{association.id}][]"
        unselect linkables[2]["internal_name"], from: "associations[#{association.id}][]"
      end

      click_on "Save"
    end

    def then_i_can_view_the_associations
      @associations.each do |association|
        within("##{association.id}") do
          expect(page).to have_content linkables[0]["internal_name"]
          expect(page).to have_content linkables[1]["internal_name"]
          expect(page).not_to have_content linkables[2]["internal_name"]
        end
      end
    end

    def and_the_preview_creation_succeeded
      expect(@request).to have_been_requested
      expect(page).to have_content "Preview creation successful"

      expect(a_request(:put, /content/).with { |req|
        expect(JSON.parse(req.body)["links"]).to eq(edition_links)
      }).to have_been_requested
    end

    def edition_links
      Hash[@associations.map { |association|
        [association.id, [linkables[0]["content_id"], linkables[1]["content_id"]]]
      }]
    end

    def linkables
      @linkables ||= 3.times.map do |i|
        { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable #{i}" }
      end
    end
  end
end
