# frozen_string_literal: true

RSpec.describe ScheduledPublishingWorker, type: :worker do
  describe "#perform" do
    it "calls PublishService if edition can be published" do
      edition = create(:edition,
                       :scheduled,
                       scheduled_publishing_datetime: Time.current)
      user = edition.status.created_by

      expect_any_instance_of(PublishService)
        .to receive(:publish)
        .with(user: user, with_review: edition.status.details.reviewed)

      ScheduledPublishingWorker.new.perform(edition.id)
    end

    it "aborts the worker and does not call Publish Service if edition id cannot be found" do
      expect_any_instance_of(PublishService).not_to receive(:publish)
      ScheduledPublishingWorker.new.perform(100)
    end

    it "aborts the worker and does not call Publish Service if the edition is not scheduled" do
      edition = create(:edition)
      expect_any_instance_of(PublishService).not_to receive(:publish)

      ScheduledPublishingWorker.new.perform(edition.id)
    end
  end
end
