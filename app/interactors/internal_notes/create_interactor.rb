# frozen_string_literal: true

class InternalNotes::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :internal_note,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_note_presence

      create_internal_note
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_note_presence
    note = params.fetch(:internal_note)
    context.fail! if note.chomp.blank?
  end

  def create_internal_note
    context.internal_note = InternalNote.create!(
      body: params[:internal_note].chomp,
      edition: edition,
      created_by: user,
    )
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(
      entry_type: :internal_note,
      edition: edition,
      details: internal_note,
      created_by: user,
    )
  end
end
