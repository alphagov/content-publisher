RSpec.describe ScheduledPublishingJob do
  include ActiveJob::TestHelper

  before do
    populate_default_government_bulk_data
    stub_any_publishing_api_call
  end

  let(:scheduled_edition) do
    scheduling = create(:scheduling, reviewed: true, publish_time: Time.current.yesterday)
    create(:edition, :scheduled, scheduling: scheduling)
  end

  it "can publish a scheduled edition" do
    expect { described_class.perform_now(scheduled_edition.id) }
      .to change { scheduled_edition.reload.state }
      .to("published")
  end

  it "creates a timeline entry" do
    expect { described_class.perform_now(scheduled_edition.id) }
      .to change(TimelineEntry, :count)
      .by(1)
  end

  it "can notify the edition editors" do
    expect(ScheduledPublishMailer)
      .to receive(:success_email)
      .with(scheduled_edition.created_by, scheduled_edition, an_instance_of(Status))
      .and_call_original

    described_class.perform_now(scheduled_edition.id)
  end

  context "when the edition isn't scheduled" do
    it "doesn't publish the edition" do
      edition = create(:edition)

      expect { described_class.perform_now(edition.id) }
        .not_to change { edition.reload.state }
        .from("draft")
    end
  end

  context "when the publish time is in the future" do
    it "doesn't publish the edition" do
      scheduling = create(:scheduling, reviewed: true, publish_time: Time.current.tomorrow)
      edition = create(:edition, :scheduled, scheduling: scheduling)

      expect { described_class.perform_now(edition.id) }
        .not_to change { edition.reload.state }
        .from("scheduled")
    end
  end

  context "when an exception is raised" do
    before do
      allow(PublishDraftEditionService).to receive(:new).and_raise(RuntimeError)
      allow(RescueScheduledPublishingService).to receive(:call)
    end

    it "retries the job" do
      described_class.perform_now(scheduled_edition.id)

      expect(described_class).to have_been_enqueued
    end

    it "when it is out of retries it calls the failed service" do
      expect(RescueScheduledPublishingService).to receive(:call)
        .with(edition_id: scheduled_edition.id)

      perform_enqueued_jobs do
        described_class.perform_later(scheduled_edition.id)
      end
    end
  end
end
