# frozen_string_literal: true

RSpec.describe ScheduleService do
  before(:each) do
    stub_default_publishing_api_put_intent
  end

  describe "#schedule" do
    it "sets an edition's state to 'scheduled'" do
      edition = create(:edition)
      ScheduleService.new(edition).schedule

      expect(edition).to be_scheduled
    end

    it "saves the edition's pre-scheduling status" do
      edition = create(:edition)
      pre_scheduling_status = edition.status
      ScheduleService.new(edition).schedule

      expect(edition.status.details.pre_scheduled_status).to eq(pre_scheduling_status)
    end

    it "creates a timeline entry" do
      edition = create(:edition)
      ScheduleService.new(edition).schedule

      expect(edition.timeline_entries.first.entry_type).to eq("scheduled")
    end

    it "makes a request to publishing-api to create / update a publishing intent" do
      document_type = create(
        :document_type,
        publishing_metadata: DocumentType::PublishingMetadata.new(
          "rendering_app": "government-frontend",
        ),
      )
      publish_time = Time.current.tomorrow.at_noon
      edition = create(:edition, scheduled_publishing_datetime: publish_time, document_type_id: document_type.id)
      base_path = edition.base_path

      expected_payload = {
        publish_time: publish_time,
        publishing_app: "content-publisher",
        rendering_app: "government-frontend",
      }

      expected_request = stub_publishing_api_put_intent(base_path, expected_payload)

      ScheduleService.new(edition).schedule

      assert_requested expected_request
    end

    context "when the edition has been reviewed" do
      it "sets the scheduling reviewed state to true" do
        edition = create(:edition)
        ScheduleService.new(edition).schedule(reviewed: true)

        expect(edition.status.details.reviewed).to be true
      end
    end

    context "when the edition has not been reviewed" do
      it "sets the scheduling reviewed state to false" do
        edition = create(:edition)
        ScheduleService.new(edition).schedule(reviewed: false)

        expect(edition.status.details.reviewed).to be false
      end
    end
  end
end
