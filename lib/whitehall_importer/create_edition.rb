module WhitehallImporter
  class CreateEdition
    attr_reader :document_import, :current, :whitehall_edition, :edition_number, :user_ids

    def self.call(*args)
      new(*args).call
    end

    def initialize(document_import:, whitehall_edition:, current: true, edition_number: 1, user_ids: {})
      @document_import = document_import
      @current = current
      @whitehall_edition = whitehall_edition
      @edition_number = edition_number
      @user_ids = user_ids
    end

    def call
      check_only_in_english

      edition = if whitehall_edition["state"] == "withdrawn"
                  create_withdrawn_edition
                elsif whitehall_edition["state"] == "scheduled"
                  create_scheduled_edition
                elsif unpublished_edition? && history.edited_after_unpublishing?
                  split_unpublished_edition
                elsif unpublished_edition?
                  create_removed_edition
                else
                  state = MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"])
                  status = build_status(state)
                  create_edition(status: status, current: current, edition_number: edition_number)
                end

      create_revision_history(edition)
      create_notes(edition)
      create_fact_checks(edition)

      edition.tap { |e| access_limit(e) }
    end

  private

    def revision
      @revision ||= CreateRevision.call(document_import, whitehall_edition)
    end

    def history
      @history ||= EditionHistory.new(whitehall_edition["revision_history"])
    end

    def unpublished_edition?
      whitehall_edition["unpublishing"] && %w[submitted rejected draft].include?(whitehall_edition["state"])
    end

    def split_unpublished_edition
      unpublishing_event = history.last_unpublishing_event!
      create_edition(
        status: build_status("removed", build_removal),
        current: false,
        edition_number: edition_number,
        last_event: unpublishing_event,
      )

      create_edition(
        status: build_status(MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"])),
        edition_number: edition_number + 1,
        current: true,
        create_event: history.next_event!(unpublishing_event),
      )
    end

    def create_removed_edition
      removed_status = build_status("removed", build_removal)
      create_edition(status: removed_status, current: current, edition_number: edition_number)
    end

    def check_only_in_english
      raise AbortImportError, "Edition has an unsupported locale" unless only_english_translation?
    end

    def only_english_translation?
      whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
    end

    def create_withdrawn_edition
      create_edition(status: build_status("published"),
                     current: current,
                     edition_number: edition_number).tap { |edition| set_withdrawn_status(edition) }
    end

    def set_withdrawn_status(edition)
      unless whitehall_edition["unpublishing"]
        raise AbortImportError, "Cannot create withdrawn status without an unpublishing"
      end

      withdrawal = Withdrawal.new(
        published_status: edition.status,
        public_explanation: whitehall_edition["unpublishing"]["explanation"],
        withdrawn_at: whitehall_edition["unpublishing"]["created_at"],
      )

      edition.update!(status: build_status("withdrawn", withdrawal))
    end

    def create_scheduled_edition
      unless whitehall_edition["scheduled_publication"]
        raise AbortImportError, "Cannot create scheduled status without scheduled_publication"
      end

      pre_scheduled_state = history.last_state_event("submitted") ? "submitted_for_review" : "draft"
      edition = create_edition(status: build_status(pre_scheduled_state),
                               current: current,
                               edition_number: edition_number)
      scheduling = Scheduling.new(pre_scheduled_status: edition.status,
                                  reviewed: !whitehall_edition["force_published"],
                                  publish_time: whitehall_edition["scheduled_publication"])
      edition.update!(status: build_status("scheduled", scheduling))
      edition
    end

    def build_removal
      unpublishing = whitehall_edition["unpublishing"]
      unless unpublishing
        raise AbortImportError, "Cannot create removal status without an unpublishing"
      end

      Removal.new(
        explanatory_note: unpublishing["explanation"],
        alternative_url: unpublishing["alternative_url"],
        redirect: unpublishing["alternative_url"].present?,
      )
    end

    def build_status(state, details = nil)
      last_state_event = history.last_state_event!(whitehall_edition["state"])

      Status.new(
        state: state,
        revision_at_creation: revision,
        created_by_id: user_ids[last_state_event["whodunnit"]],
        created_at: last_state_event["created_at"],
        details: details,
      )
    end

    def create_edition(status:, edition_number:, current:, create_event: nil, last_event: nil)
      create_event ||= history.create_event!
      last_event ||= whitehall_edition["revision_history"].last

      editor_ids = history.editors.map { |editor| user_ids[editor] }.compact
      published_at = history.last_state_event!("published")["created_at"] if status.live? || status.superseded?

      Edition.create!(
        document: document_import.document,
        number: edition_number,
        revision_synced: false,
        revision: revision,
        status: status,
        current: current,
        live: whitehall_edition["state"].in?(%w(published withdrawn)),
        created_at: create_event["created_at"],
        updated_at: last_event["created_at"],
        created_by_id: user_ids[create_event["whodunnit"]],
        last_edited_at: last_event["created_at"],
        last_edited_by_id: user_ids[last_event["whodunnit"]],
        published_at: published_at,
        editor_ids: editor_ids,
      )
    end

    def access_limit(edition)
      return unless whitehall_edition["access_limited"]

      edition.access_limit = AccessLimit.new(
        created_at: whitehall_edition["created_at"],
        edition: edition,
        revision_at_creation: edition.revision,
        limit_type: "tagged_organisations",
      )

      edition.save!
    end

    def create_revision_history(edition)
      whitehall_edition["revision_history"].each do |event|
        entry_type = history.imported_entry_type(event, edition_number)
        next if entry_type.nil?

        details = create_whitehall_imported_entry(entry_type)
        create_timeline_entry(details,
                              edition,
                              event["created_at"],
                              event["whodunnit"])
      end
    end

    def create_notes(edition)
      whitehall_edition["editorial_remarks"].each do |event|
        contents = {
          body: event["body"],
        }
        details = create_whitehall_imported_entry("internal_note", contents)
        create_timeline_entry(details,
                              edition, event["created_at"], event["author_id"])
      end
    end

    def create_fact_checks(edition)
      whitehall_edition["fact_check_requests"].each do |event|
        create_fact_check_request(edition, event)
        create_fact_check_response(edition, event) if event["comments"].present?
      end
    end

    def create_fact_check_request(edition, event)
      contents = {
        email_address: event["email_address"],
        instructions: event["instructions"],
      }
      details = create_whitehall_imported_entry("fact_check_request", contents)
      create_timeline_entry(details,
                            edition, event["created_at"], event["requestor_id"])
    end

    def create_fact_check_response(edition, event)
      contents = {
        email_address: event["email_address"],
        comments: event["comments"],
      }
      details = create_whitehall_imported_entry("fact_check_response", contents)
      create_timeline_entry(details, edition, event["updated_at"])
    end

    def create_whitehall_imported_entry(entry_type, contents = {})
      TimelineEntry::WhitehallImportedEntry.create!(
        entry_type: entry_type,
        contents: contents,
      )
    end

    def create_timeline_entry(details, edition, created_at, whitehall_created_by_id = nil)
      TimelineEntry.create!(
        entry_type: :whitehall_migration,
        created_by_id: user_ids[whitehall_created_by_id],
        created_at: created_at,
        edition: edition,
        document: edition.document,
        details: details,
      )
    end
  end
end
