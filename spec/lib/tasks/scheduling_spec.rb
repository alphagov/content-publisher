RSpec.describe "Scheduling tasks" do
  include ActiveJob::TestHelper

  describe "scheduling:repopulate" do
    before { Rake::Task["scheduling:repopulate"].reenable }

    it "schedules ScheduledPublishingJob workers on current, scheduled editions" do
      publish_time = Date.tomorrow.noon
      scheduled_edition = create(:edition, :scheduled, publish_time:)
      create(:edition, :scheduled, current: false)
      create(:edition)

      Rake::Task["scheduling:repopulate"].invoke

      expect(enqueued_jobs.count).to eq 1
      expect(enqueued_jobs.first)
        .to match(hash_including(args: [scheduled_edition.id], at: publish_time.to_i))
    end
  end
end
