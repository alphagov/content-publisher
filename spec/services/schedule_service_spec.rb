# frozen_string_literal: true

RSpec.describe ScheduleService do
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
