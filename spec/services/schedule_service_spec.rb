# frozen_string_literal: true

RSpec.describe ScheduleService do
  let(:publishing_api_payload) { instance_double(PublishingApiPayload, intent_payload: "payload") }

  include ActiveJob::TestHelper

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  before(:each) do
    stub_default_publishing_api_put_intent
    allow(PublishingApiPayload).to receive(:new) { publishing_api_payload }
  end

  describe "#schedule" do
    let(:edition) { create :edition, proposed_publish_time: Time.current.tomorrow }

    it "sets an edition's state to 'scheduled'" do
      ScheduleService.new(edition).schedule(reviewed: true)
      expect(edition).to be_scheduled
    end

    it "saves the edition's pre-scheduling status" do
      pre_scheduling_status = edition.status
      ScheduleService.new(edition).schedule(reviewed: true)
      expect(edition.status.details.pre_scheduled_status).to eq(pre_scheduling_status)
    end

    it "clears the editions proposed publish time" do
      ScheduleService.new(edition).schedule(reviewed: true)
      expect(edition.reload.proposed_publish_time).to be_nil
    end

    it "creates a timeline entry" do
      ScheduleService.new(edition).schedule(reviewed: true)
      expect(edition.timeline_entries.first.entry_type).to eq("scheduled")
    end

    it "creates a publishing intent" do
      request = stub_publishing_api_put_intent(edition.base_path, '"payload"')
      ScheduleService.new(edition).schedule(reviewed: true)
      expect(request).to have_been_requested
    end

    context "when the edition has been reviewed" do
      it "sets the scheduling reviewed state to true" do
        ScheduleService.new(edition).schedule(reviewed: true)
        expect(edition.status.details.reviewed).to be true
      end
    end

    context "when the edition has not been reviewed" do
      it "sets the scheduling reviewed state to false" do
        ScheduleService.new(edition).schedule(reviewed: false)
        expect(edition.status.details.reviewed).to be false
      end
    end

    it "schedules the edition to publish" do
      datetime = edition.proposed_publish_time
      ScheduleService.new(edition).schedule(reviewed: false)
      expect(enqueued_jobs.count).to eq 1
      expect(enqueued_jobs.first[:args].first).to eq edition.id
      expect(enqueued_jobs.first[:at].to_i).to eq datetime.to_i
    end
  end

  describe "#reschedule" do
    let(:edition) do
      create(:edition,
             :scheduled,
             scheduling: create(:scheduling, publish_time: Time.current.tomorrow))
    end
    let(:publish_time) { Time.current.advance(days: 2) }

    it "maintains the edition's state as 'scheduled'" do
      ScheduleService.new(edition).reschedule(publish_time: publish_time)
      expect(edition).to be_scheduled
    end

    it "creates a new scheduling status using details from the previous" do
      old_scheduling = edition.status.details
      ScheduleService.new(edition).reschedule(publish_time: publish_time)
      new_scheduling = edition.status.details
      expect(new_scheduling.publish_time).to eq publish_time
      expect(new_scheduling.pre_scheduled_status).to eq old_scheduling.pre_scheduled_status
      expect(new_scheduling.reviewed).to eq old_scheduling.reviewed
    end

    it "creates another timeline entry" do
      ScheduleService.new(edition).reschedule(publish_time: publish_time)
      expect(edition.timeline_entries.last.entry_type).to eq "schedule_updated"
    end

    it "updates the existing publishing intent" do
      request = stub_publishing_api_put_intent(edition.base_path, '"payload"')
      ScheduleService.new(edition).reschedule(publish_time: publish_time)
      expect(request).to have_been_requested
    end

    it "schedules the edition to publish" do
      ScheduleService.new(edition).reschedule(publish_time: publish_time)
      expect(enqueued_jobs.count).to eq 1
      expect(enqueued_jobs.last[:args].first).to eq edition.id
      expect(enqueued_jobs.last[:at].to_i).to eq publish_time.to_i
    end
  end
end
