# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Create a document" do
  DocumentTypeSchema.all.each do |schema|
    next if schema.managed_elsewhere

    scenario "User creates #{schema.name}" do
      @schema = schema

      when_i_click_on_create_a_document
      and_i_choose_a_supertype
      and_i_choose_a_document_type
      and_i_fill_in_the_form_fields
      then_i_see_the_document_exists
    end

    def when_i_click_on_create_a_document
      visit "/"
      click_on "New document"
    end

    def and_i_choose_a_supertype
      choose @schema.supertype.label
      click_on "Continue"
    end

    def and_i_choose_a_document_type
      choose @schema.name
      click_on "Continue"
    end

    def and_i_fill_in_the_form_fields
      # Clicking save will make a request, but we don't care about the
      # particulars, which are tested in the feature test of the "edit" flow
      @put_content_request = stub_any_publishing_api_put_content
      @lookup_base_path_request = publishing_api_has_lookups("#{@schema.path_prefix}/a-great-title" => nil)
      fill_in "document[title]", with: "A great title"
      click_on "Save"
    end

    def then_i_see_the_document_exists
      expect(@put_content_request).to have_been_requested
      expect(@lookup_base_path_request).to have_been_requested
      expect(Document.last.title).to eq "A great title"
      expect(page).to have_content @schema.id
      expect(page).to have_content "A great title"
    end
  end
end
