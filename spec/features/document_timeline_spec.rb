# frozen_string_literal: true

RSpec.feature "Document timeline" do
  scenario "User edits the document and looks at timeline" do
    when_i_start_to_create_a_document
    the_timeline_has_a_create_entry

    when_i_update_the_document
    the_timeline_has_a_update_entry

    when_i_submit_the_document
    the_timeline_has_a_submit_entry

    when_i_publish_the_document_without_review
    the_timeline_has_a_publish_without_review_entry

    when_i_approve_the_document
    the_timeline_has_a_approval_entry
  end

  def when_i_start_to_create_a_document
    @schema = DocumentTypeSchema.find("news_story")
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("news").label
    click_on "Continue"
    choose @schema.label
    click_on "Continue"

    @document = Document.last
  end

  def the_timeline_has_a_create_entry
    visit document_path(@document)

    within find(".timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.created")
    end
  end

  def when_i_update_the_document
    stub_any_publishing_api_put_content

    visit edit_document_path(@document)
    fill_in "Title", with: "This is a new title"
    click_on "Save"
  end

  def the_timeline_has_a_update_entry
    within find(".timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.updated_content")
    end
  end

  def when_i_submit_the_document
    click_on "Submit for 2i review"
  end

  def the_timeline_has_a_submit_entry
    within find(".timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.submitted")
    end
  end

  def when_i_publish_the_document_without_review
    stub_any_publishing_api_publish

    click_on "Publish"
    click_on "Confirm publish"
  end

  def the_timeline_has_a_publish_without_review_entry
    visit document_path(@document)

    within find(".timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.published_without_review")
    end
  end

  def when_i_approve_the_document
    click_on "Approve"
  end

  def the_timeline_has_a_approval_entry
    within find(".timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.approved")
    end
  end
end
