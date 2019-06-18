# frozen_string_literal: true

RSpec.describe ScheduledPublishingJob, inline: true do
  describe "#perform" do
    context "scheduled publishing is successful" do
      before do
        @publish_service = instance_double(PublishService, publish: nil)
        message_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)
        allow(ScheduledPublishMailer).to receive(:success_email).and_return(message_delivery)
      end

      it "calls PublishService if edition can be published" do
        edition = create(:edition,
                         :scheduled,
                         scheduling: build(:scheduling, publish_time: Time.current))
        user = edition.status.created_by

        expect(PublishService).to receive(:new).with(edition) { @publish_service }
        expect(@publish_service)
          .to receive(:publish)
          .with(user: user, with_review: edition.status.details.reviewed)

        ScheduledPublishingJob.perform_now(edition.id)
      end

      it "calls ScheduledPublishMailer for each editor of the edition" do
        editor_one = create(:user, email: "someone@example.com")
        editor_two = create(:user, email: "someone-else@example.com")
        edition = create(:edition,
                         :scheduled,
                         revision: create(:revision, created_by: editor_two),
                         scheduling: create(:scheduling, publish_time: Time.current),
                         created_by: editor_one)

        allow(PublishService).to receive(:new).with(edition) { @publish_service }

        expect(ScheduledPublishMailer).to receive(:success_email).with(edition, editor_one)
        expect(ScheduledPublishMailer).to receive(:success_email).with(edition, editor_two)

        ScheduledPublishingJob.perform_now(edition.id)
      end
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
                       publish_time: Time.current.tomorrow)

      expect_any_instance_of(PublishService).not_to receive(:publish)
      expect { ScheduledPublishingJob.perform_now(edition.id) }.to_not raise_error
    end
  end
end
