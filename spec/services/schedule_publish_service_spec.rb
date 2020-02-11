RSpec.describe SchedulePublishService do
  let(:payload) do
    instance_double(SchedulePublishService::Payload, intent_payload: "payload")
  end

  include ActiveJob::TestHelper

  before do
    stub_any_publishing_api_put_intent
    allow(SchedulePublishService::Payload).to receive(:new) { payload }
  end

  describe "#call" do
    let(:user) { create :user }
    let(:edition) { create :edition, proposed_publish_time: Time.current.tomorrow }
    let(:scheduling) { create :scheduling, publish_time: edition.proposed_publish_time }

    it "sets an edition's state to 'scheduled'" do
      described_class.call(edition, user, scheduling)
      expect(edition).to be_scheduled
    end

    it "clears the editions proposed publish time" do
      described_class.call(edition, user, scheduling)
      expect(edition.reload.proposed_publish_time).to be_nil
    end

    it "creates a publishing intent" do
      request = stub_publishing_api_put_intent(edition.base_path, '"payload"')
      described_class.call(edition, user, scheduling)
      expect(request).to have_been_requested
    end

    it "schedules the edition to publish" do
      datetime = edition.proposed_publish_time
      described_class.call(edition, user, scheduling)
      expect(enqueued_jobs.count).to eq 1
      expect(enqueued_jobs.first[:args].first).to eq edition.id
      expect(enqueued_jobs.first[:at].to_i).to eq datetime.to_i
    end
  end
end
