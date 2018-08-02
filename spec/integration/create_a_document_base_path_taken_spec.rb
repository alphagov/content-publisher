# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document where all base path variants are taken", type: :feature, js: true do
  # This test creates a 409 when a new path cannot be generated
  # this logs an error to the console. Doesn't seem to be better
  # way to prevent certain JS errors failing tests so we disable
  # the feature entirely here :(
  before(:all) { Capybara::Chromedriver::Logger.raise_js_errors = false }
  after(:all) { Capybara::Chromedriver::Logger.raise_js_errors = true }

  DocumentTypeSchema.all.each do |schema|
    next if schema.managed_elsewhere

    scenario "User creates #{schema.name}" do
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
      @request = publishing_api_has_lookups(
        "#{@schema.path_prefix}/a-great-title": "a-content-id",
        "#{@schema.path_prefix}/a-great-title-1": "a-content-id",
        "#{@schema.path_prefix}/a-great-title-2": "a-content-id",
        "#{@schema.path_prefix}/a-great-title-3": "a-content-id",
        "#{@schema.path_prefix}/a-great-title-4": "a-content-id",
        "#{@schema.path_prefix}/a-great-title-5": "a-content-id",
      )
      fill_in("document[title]", with: "A great title")
      page.find("body").click
    end

    def then_i_see_a_path_taken_warning_message
      expect(page).to have_content "Unable to preview address, please edit title and try again."
      expect(@request).to have_been_requested.times(6)
    end
  end
end
