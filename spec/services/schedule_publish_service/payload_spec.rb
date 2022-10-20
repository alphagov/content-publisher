RSpec.describe SchedulePublishService::Payload do
  describe "#intent_payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type, rendering_app: "government-frontend")
      publish_time = Time.zone.now.tomorrow.at_noon

      edition = build(:edition,
                      :scheduled,
                      document_type:,
                      publish_time:)

      payload = described_class.new(edition).intent_payload

      payload_hash = {
        publish_time:,
        publishing_app: PublishingApiPayload::PUBLISHING_APP,
        rendering_app: "government-frontend",
      }

      expect(payload).to match a_hash_including(payload_hash)
    end
  end
end
