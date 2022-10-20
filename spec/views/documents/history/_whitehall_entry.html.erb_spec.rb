RSpec.describe "documents/history/_whitehall_entry" do
  it "shows an imported timeline entry without an author" do
    freeze_time do
      timeline_entry = create(:timeline_entry,
                              :whitehall_imported,
                              whitehall_entry_type: :new_edition,
                              created_by: nil)
      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered)
        .to have_content(I18n.t!("documents.history.dateline_no_user",
                                 date: Time.zone.now.to_fs(:date),
                                 time: Time.zone.now.to_fs(:time)))
    end
  end

  it "shows an imported timeline entry with an author" do
    freeze_time do
      timeline_entry = create(:timeline_entry,
                              :whitehall_imported,
                              whitehall_entry_type: :new_edition)

      render template: described_template, locals: { entry: timeline_entry }
      expect(rendered)
        .to have_content(I18n.t!("documents.history.dateline_user",
                                 date: Time.zone.now.to_fs(:date),
                                 time: Time.zone.now.to_fs(:time),
                                 user: timeline_entry.created_by.name))
    end
  end

  it "does not highlight an imported internal note timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :internal_note)

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported internal note timeline entry" do
    note = "This is a note"
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :internal_note,
                            whitehall_entry_contents: { body: note })

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).to have_content(note)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end

  it "does not highlight an imported fact check request timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_request)

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported fact check request timeline entry" do
    email = "someone@somewhere.com"
    instructions = "Do something, then do something else"
    timeline_entry = create(
      :timeline_entry,
      :whitehall_imported,
      whitehall_entry_type: :fact_check_request,
      whitehall_entry_contents: { email_address: email, instructions: },
    )

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).to have_content(email)
    expect(rendered).to have_content(instructions)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end

  it "does not highlight an imported fact check response timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_response)

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported fact check response timeline entry" do
    email = "someone@somewhere.com"
    comments = "I have done what you requested"
    timeline_entry = create(
      :timeline_entry,
      :whitehall_imported,
      whitehall_entry_type: :fact_check_response,
      whitehall_entry_contents: { email_address: email, comments: },
    )

    render template: described_template, locals: { entry: timeline_entry }
    expect(rendered).to have_content(email)
    expect(rendered).to have_content(comments)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end
end
