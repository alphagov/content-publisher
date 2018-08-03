# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit document associations", type: :feature do
  DocumentTypeSchema.all.each do |schema|
    scenario "User edits associations to a #{schema.name}" do
      @schema = schema

      given_there_is_a_document_with_associations
      when_i_visit_the_document_page
      and_i_click_on_edit_associations
      and_i_edit_the_associations
      then_i_can_view_the_associations
      and_the_preview_creation_succeeded
    end

    def given_there_is_a_document_with_associations
      @document = create(:document, title: "Title", document_type: @schema.id)
      @association_schemas = @document.document_type_schema.associations

      @association_schemas.each do |schema|
        publishing_api_has_linkables(linkables, document_type: schema.document_type)
      end

      initial_associations = @association_schemas.map do |schema|
        [schema.id, [linkables[2]["content_id"]]]
      end

      @document.update(associations: Hash[initial_associations])
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

      @association_schemas.each do |schema|
        select linkables[0]["internal_name"], from: "associations[#{schema.id}][]"
        select linkables[1]["internal_name"], from: "associations[#{schema.id}][]"
        unselect linkables[2]["internal_name"], from: "associations[#{schema.id}][]"
      end

      click_on "Save"
    end

    def then_i_can_view_the_associations
      @association_schemas.each do |schema|
        within("##{schema.id}") do
          expect(page).to have_content linkables[0]["internal_name"]
          expect(page).to have_content linkables[1]["internal_name"]
          expect(page).not_to have_content linkables[2]["internal_name"]
        end
      end
    end

    def and_the_preview_creation_succeeded
      return if @schema.managed_elsewhere

      expect(@request).to have_been_requested
      expect(page).to have_content "Preview creation successful"

      expect(a_request(:put, /content/).with { |req|
        expect(req.body).to be_valid_against_schema(@schema.publishing_metadata.schema_name)
        expect(JSON.parse(req.body)["links"]).to eq(edition_links)
      }).to have_been_requested
    end

    def edition_links
      Hash[@association_schemas.map { |schema|
        [schema.id, [linkables[0]["content_id"], linkables[1]["content_id"]]]
      }]
    end

    def linkables
      @linkables ||= 3.times.map do |i|
        { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable #{i}" }
      end
    end
  end
end
