RSpec.describe "documents/history/_whitehall_entry.html.erb" do
  it "shows an imported timeline entry without an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition,
                            created_by: nil)
    render partial: "documents/history/whitehall_entry", locals: { entry: timeline_entry }
    expect(rendered).not_to have_content(I18n.t!("documents.history.by"))
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end

  it "shows an imported timeline entry with an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition)

    render partial: "documents/history/whitehall_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_content(I18n.t!("documents.history.by") + " John Smith")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end

  it "does not highlight an imported internal note timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :internal_note)
    timeline_entry.details[:contents] = {}

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported internal note timeline entry" do
    note = "This is a note"
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :internal_note)
    timeline_entry.details[:contents] = { body: note }

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).to have_content(note)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end

  it "does not highlight an imported fact check request timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_request)
    timeline_entry.details[:contents] = {}

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported fact check request timeline entry" do
    email = "someone@somewhere.com"
    instructions = "Do something, then do something else"
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_request)
    timeline_entry.details[:contents] = {
      email_address: email,
      instructions: instructions,
    }

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).to have_content(email)
    expect(rendered).to have_content(instructions)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end

  it "does not highlight an imported fact check response timeline entry without content" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_response)
    timeline_entry.details[:contents] = {}

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).not_to have_selector(".app-timeline-entry--highlighted")
  end

  it "shows the contents of an imported fact check response timeline entry" do
    email = "someone@somewhere.com"
    comments = "I have done what you requested"
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :fact_check_response)
    timeline_entry.details[:contents] = {
      email_address: email,
      comments: comments,
    }

    render partial: "documents/history/whitehall_entry",
                    locals: { entry: timeline_entry }
    expect(rendered).to have_content(email)
    expect(rendered).to have_content(comments)
    expect(rendered).to have_selector(".app-timeline-entry--highlighted")
  end
end
