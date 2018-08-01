# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document", type: :feature do
  DocumentTypeSchema.all.each do |schema|
    next if schema.managed_elsewhere

    scenario "User creates #{schema.name}" do
      pending("Alex to fix JS problems")
      @schema = schema

      when_i_click_on_create_a_document
      and_i_choose_a_supertype
      and_i_choose_a_document_type
      and_i_fill_in_the_title_but_the_base_path_has_already_been_used
      then_i_see_a_path_taken_warning_message
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

    def and_i_fill_in_the_title_but_the_base_path_has_already_been_used
      @request = publishing_api_has_lookups("#{@schema.path_prefix}/a-great-title" => "a-content-id")
      fill_in("document[title]", with: "A great title")
    end

    def then_i_see_a_path_taken_warning_message
      expect(@request).to have_been_requested
      expect(page).to have_content "Path is taken, please edit the title."
    end
  end
end
