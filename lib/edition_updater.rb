class EditionUpdater
  def self.call(*args, &block)
    self.new(*args).call(&block)
  end

  def initialize(content_id, locale: nil, user_email: nil)
    @content_id = content_id
    @locale = locale || "en"
    @user = User.find_by!(email: user_email) if user_email
  end

  def call
    Edition.transaction do
      edition = Edition.lock.find_current(document: "#{@content_id}:#{@locale}")
      raise "Edition must be editable" unless edition.editable?

      updater = Versioning::RevisionUpdater.new(edition.revision, @user)
      yield edition, updater

      raise "Expected an updated revision" unless updater.changed?

      EditDraftEditionService.call(edition,
                                   @user,
                                   revision: updater.next_revision)

      edition.save!
      FailsafeDraftPreviewService.call(edition)
    end
  end
end
