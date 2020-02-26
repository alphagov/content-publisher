class CreateNextEditionService < ApplicationService
  def initialize(current_edition:, user:, discarded_edition: nil)
    @current_edition = current_edition
    @user = user
    @discarded_edition = discarded_edition
  end

  def call
    raise "Can only create a next edition from a live edition" unless current_edition.live

    current_edition.update!(current: false)
    EditDraftEditionService.call(next_edition, user, current: true, revision: next_revision)
    AssignEditionStatusService.call(next_edition, user: user, state: :draft)
    next_edition.save!
    next_edition
  end

private

  attr_reader :current_edition, :user, :discarded_edition

  def next_edition
    @next_edition ||= begin
      document = current_edition.document
      discarded_edition || Edition.new(document: document,
                                       number: document.next_edition_number,
                                       created_by: user)
    end
  end

  def next_revision
    updater = Versioning::RevisionUpdater.new(current_edition.revision, user)
    updater.assign(change_note: "",
                   update_type: "major",
                   proposed_publish_time: nil,
                   change_history: change_history)
    updater.next_revision
  end

  def change_history
    if !current_edition.major? || current_edition.change_note.empty? || current_edition.first?
      return current_edition.change_history
    end

    current_edition.change_history.prepend(
      "id" => SecureRandom.uuid,
      "note" => current_edition.change_note,
      "public_timestamp" => current_edition.published_at.rfc3339,
    )
  end
end
