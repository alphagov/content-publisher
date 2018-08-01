# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document that is managed elsewhere", type: :feature do
  DocumentTypeSchema.all.each do |schema|
    next unless schema.managed_elsewhere

    scenario "User creates a #{schema.name}" do
      @schema = schema

      when_i_click_on_create_a_document
      and_i_choose_a_document_that_is_not_managed_in_this_app
      then_i_am_redirected_to_the_application_that_manages_the_content
    end

    def when_i_click_on_create_a_document
      visit "/"
      click_on "New document"
    end

    def and_i_choose_a_document_that_is_not_managed_in_this_app
      choose @schema.supertype.label
      click_on "Continue"

      choose @schema.name
      click_on "Continue"
    end

    def then_i_am_redirected_to_the_application_that_manages_the_content
      expect(page.current_path).to eql @schema.managed_elsewhere.fetch("path")
      expect(page).to have_content "You've been redirected"
    end
  end
end
