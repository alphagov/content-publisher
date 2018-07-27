# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit a document", type: :feature do
  DocumentTypeSchema.all.each do |schema|
    next if schema.managed_elsewhere?

    scenario "User edits #{schema.name}" do
      @schema = schema

      given_there_is_a_document
      when_i_go_to_edit_the_document
      and_i_fill_in_the_fields
      then_i_see_the_document_is_saved
      and_the_preview_creation_succeeded
    end

    def given_there_is_a_document
      create :document, document_type: @schema.document_type
    end

    def when_i_go_to_edit_the_document
      visit document_path(Document.last)
      click_on "Edit document"
      @request = stub_publishing_api_put_content(Document.last.content_id, {})
    end

    def and_i_fill_in_the_fields
      @schema.fields do |field|
        # TODO: this currently works because the only field type (body) accepts
        # a string. Once there are other field types we'll need to expand on this.
        fill_in "document[contents][#{field.id}]", with: SecureRandom.hex
      end

      fill_in "document[summary]", with: "A summary of the release."
      click_on "Save"
    end

    def then_i_see_the_document_is_saved
      expect(page).to have_content "A summary of the release."
    end

    def and_the_preview_creation_succeeded
      expect(@request).to have_been_requested
      expect(page).to have_content "Preview creation successful"

      expect(a_request(:put, /content/).with { |req|
        expect(req.body).to be_valid_against_schema(@schema.schema_name)
        expect(JSON.parse(req.body)["description"]).to eq "A summary of the release."
      }).to have_been_requested
    end
  end
end
