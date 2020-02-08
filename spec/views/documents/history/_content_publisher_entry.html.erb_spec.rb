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

  context "when the timeline entry is for a removal" do
    it "can show an explanatory_note" do
      removal = create(:removal, explanatory_note: "My note")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render partial: "documents/history/content_publisher_entry",
             locals: { entry: timeline_entry }
      expect(rendered).to have_content("My note")
    end

    it "can show a link to an alternative URL" do
      removal = create(:removal, alternative_url: "https://example.com")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render partial: "documents/history/content_publisher_entry",
             locals: { entry: timeline_entry }
      expect(rendered).to have_content("Alternative URL https://example.com",
                                       normalize_ws: true)
      expect(rendered).to have_link("https://example.com",
                                    href: "https://example.com")
    end

    it "can show a link to an alternative URL that is a path" do
      removal = create(:removal, alternative_url: "/path")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render partial: "documents/history/content_publisher_entry",
             locals: { entry: timeline_entry }
      expect(rendered).to have_link("https://www.test.gov.uk/path",
                                    href: "https://www.test.gov.uk/path")
    end

    it "can show a redirect" do
      removal = create(:removal, redirect: true, alternative_url: "https://example.com")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render partial: "documents/history/content_publisher_entry",
             locals: { entry: timeline_entry }
      expect(rendered).to have_content("Redirected to https://example.com",
                                       normalize_ws: true)
    end
  end
end
