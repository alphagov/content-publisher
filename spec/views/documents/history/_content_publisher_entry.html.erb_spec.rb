RSpec.describe "documents/history/_content_publisher_entry" do
  it "shows a timeline entry without an author" do
    freeze_time do
      timeline_entry = create(:timeline_entry, created_by: nil)
      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered).to have_content(I18n.t!("documents.history.dateline_no_user",
                                               date: Time.zone.now.to_fs(:date),
                                               time: Time.zone.now.to_fs(:time)))
    end
  end

  it "shows a timeline entry with an author" do
    freeze_time do
      timeline_entry = create(:timeline_entry)
      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered).to have_content(I18n.t!("documents.history.dateline_user",
                                               date: Time.zone.now.to_fs(:date),
                                               time: Time.zone.now.to_fs(:time),
                                               user: timeline_entry.created_by.name))
    end
  end

  it "shows a timeline entry with content" do
    timeline_entry = create(:timeline_entry,
                            entry_type: :internal_note,
                            details: create(:internal_note))
    render template: described_template, locals: { entry: timeline_entry }
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
      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered).to have_content("My note")
    end

    it "can show a link to an alternative URL" do
      removal = create(:removal, alternative_url: "https://example.com")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render template: described_template, locals: { entry: timeline_entry }
      alternative_url = I18n.t!("documents.history.entry_content.alternative_url")
      expect(rendered).to have_content("#{alternative_url} https://example.com",
                                       normalize_ws: true)
      expect(rendered).to have_link("https://example.com",
                                    href: "https://example.com")
    end

    it "can show a link to an alternative URL that is a path" do
      removal = create(:removal, alternative_url: "/path")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered).to have_link("https://www.test.gov.uk/path",
                                    href: "https://www.test.gov.uk/path")
    end

    it "can show a redirect" do
      removal = create(:removal, redirect: true, alternative_url: "https://example.com")
      timeline_entry = create(:timeline_entry,
                              entry_type: :removed,
                              details: removal)
      render template: described_template, locals: { entry: timeline_entry }
      redirected_to = I18n.t!("documents.history.entry_content.redirected_to")
      expect(rendered).to have_content("#{redirected_to} https://example.com",
                                       normalize_ws: true)
    end
  end
end
