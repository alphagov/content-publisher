# frozen_string_literal: true

RSpec.describe ScheduledPublishingFailedService do
  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  describe "#call" do
    let(:edition) { create(:edition, :scheduled) }

    it "updates the status of the edition" do
      expect { ScheduledPublishingFailedService.new.call(edition.id) }
        .to change { edition.reload.state }
        .from("scheduled")
        .to("failed_to_publish")
    end

    it "maintains the scheduling details from the previous status" do
      expect { ScheduledPublishingFailedService.new.call(edition.id) }
        .not_to(change { edition.reload.status.details })
    end

    context "when an edition has editors" do
      it "notifies the editors" do
        edition = create(:edition, :scheduled)

        expect(ScheduledPublishMailer)
          .to receive(:failure_email)
          .with(edition, edition.created_by)
          .and_call_original

        ScheduledPublishingFailedService.new.call(edition.id)
      end
    end

    context "when an edition is not scheduled" do
      it "raises an error" do
        draft_edition = create(:edition)
        expect { ScheduledPublishingFailedService.new.call(draft_edition.id) }
          .to raise_error(RuntimeError, "Expected edition to be scheduled")
      end
    end
  end
end
