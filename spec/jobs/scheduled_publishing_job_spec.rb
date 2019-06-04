# frozen_string_literal: true

RSpec.describe ScheduledPublishingJob, inline: true do
  describe "#perform" do
    it "calls PublishService if edition can be published" do
      edition = create(:edition,
                       :scheduled,
                       scheduled_publishing_datetime: Time.current)
      user = edition.status.created_by
      publish_service = double(:publish_service, publish: nil)

      expect(PublishService).to receive(:new).with(edition) { publish_service }
      message_delivery = double(ActionMailer::MessageDelivery, deliver_later: nil)

      expect(publish_service)
        .to receive(:publish)
        .with(user: user, with_review: edition.status.details.reviewed)

      expect(ScheduledPublishMailer).to receive(:success_email).with(edition, user)
                                                               .and_return(message_delivery)

      ScheduledPublishingJob.perform_now(edition.id)
    end

    it "aborts the job if the edition does not exist (e.g. env sync)" do
      expect_any_instance_of(PublishService).not_to receive(:publish)
      expect { ScheduledPublishingJob.perform_now(100) }.to_not raise_error
    end

    it "aborts the job if the user has unscheduled the edition" do
      edition = create(:edition)
      expect_any_instance_of(PublishService).not_to receive(:publish)
      expect { ScheduledPublishingJob.perform_now(edition.id) }.to_not raise_error
    end

    it "aborts the job if the user has rescheduled the edition" do
      edition = create(:edition,
                       :scheduled,
                       scheduled_publishing_datetime: Time.current.tomorrow)

      expect_any_instance_of(PublishService).not_to receive(:publish)
      expect { ScheduledPublishingJob.perform_now(edition.id) }.to_not raise_error
    end
  end
end
