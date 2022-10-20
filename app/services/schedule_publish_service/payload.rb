class SchedulePublishService::Payload
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def intent_payload
    {
      publish_time:,
      publishing_app: PublishingApiPayload::PUBLISHING_APP,
      rendering_app:,
    }
  end

private

  def publish_time
    scheduling = edition.status.details
    scheduling.publish_time
  end

  def rendering_app
    edition.document_type.publishing_metadata.rendering_app
  end
end
