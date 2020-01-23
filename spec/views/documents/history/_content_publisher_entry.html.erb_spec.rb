# frozen_string_literal: true

RSpec.describe "documents/history/_content_publisher_entry.html.erb" do
  it "shows a timeline entry without an author" do
    timeline_entry = create(:timeline_entry,
                            created_by: nil)
    render partial: "documents/history/content_publisher_entry", locals: { entry: timeline_entry }
    expect(rendered).not_to have_content(I18n.t!("documents.history.by"))
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.created"))
  end

  it "shows a timeline entry with an author" do
    timeline_entry = create(:timeline_entry)
    render partial: "documents/history/content_publisher_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_content(I18n.t!("documents.history.by") + " John Smith")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.created"))
  end

  it "shows a timeline entry with content" do
    timeline_entry = create(:timeline_entry,
                            entry_type: :internal_note,
                            details: create(:internal_note))
    render partial: "documents/history/content_publisher_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_selector(".app-timeline-entry__content",
                                      text: "Amazing internal note")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.internal_note"))
  end
end
