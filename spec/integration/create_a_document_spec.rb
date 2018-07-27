# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document", type: :feature do
  DocumentTypeSchema.all.reject(&:managed_elsewhere?).each do |schema|
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
      choose SupertypeSchema.find(@schema.supertype).label
      click_on "Continue"
    end

    def and_i_choose_a_document_type
      choose @schema.name
      click_on "Continue"
    end

    def and_i_fill_in_the_form_fields
      # Clicking save will make a request, but we don't care about the
      # particulars, which are tested in the feature test of the "edit" flow
      stub_any_publishing_api_put_content

      fill_in "document[title]", with: "A great title"
      click_on "Save"
    end

    def then_i_see_the_document_exists
      expect(Document.last.title).to eq "A great title"
      expect(page).to have_content @schema.document_type
      expect(page).to have_content "A great title"
    end
  end
end
