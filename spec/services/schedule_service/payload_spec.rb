# frozen_string_literal: true

RSpec.describe ScheduleService::Payload do
  describe "#intent_payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type, rendering_app: "government-frontend")
      publish_time = Time.current.tomorrow.at_noon

      edition = build(:edition,
                      :scheduled,
                      document_type_id: document_type.id,
                      publish_time: publish_time)

      payload = ScheduleService::Payload.new(edition).intent_payload

      payload_hash = {
        publish_time: publish_time,
        publishing_app: PreviewService::Payload::PUBLISHING_APP,
        rendering_app: "government-frontend",
      }

      expect(payload).to match a_hash_including(payload_hash)
    end
  end
end
