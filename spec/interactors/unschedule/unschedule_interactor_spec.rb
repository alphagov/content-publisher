# frozen_string_literal: true

RSpec.describe Unschedule::UnscheduleInteractor do
  let(:scheduling) { build(:scheduling) }
  let(:edition) { create(:edition, :scheduled, scheduling: scheduling) }
  let(:user) { build(:user) }
  let(:params) { { document: edition.document.to_param } }

  describe "#call" do
    it "sets an edition's scheduled publishing datetime to nil" do
      result = Unschedule::UnscheduleInteractor.call(params: params, user: user)

      expect(result.edition.scheduled_publishing_datetime).to be nil
    end

    it "creates a timeline entry" do
      result = Unschedule::UnscheduleInteractor.call(params: params, user: user)
      timeline_entry = result.edition.timeline_entries.last

      expect(timeline_entry.entry_type).to eq("unscheduled")
    end

    context "when the scheduling reviewed state is set to true" do
      it "sets the edition's status to 'submitted_for_review'" do
        scheduling = build(:scheduling, reviewed: true)
        edition = create(:edition, :scheduled, scheduling: scheduling)
        result = Unschedule::UnscheduleInteractor.call(
          params: { document: edition.document.to_param }, user: user,
        )

        expect(result.edition.status).to be_submitted_for_review
      end
    end

    context "when the scheduling reviewed state is set to false" do
      it "sets the edition's status to 'draft'" do
        result = Unschedule::UnscheduleInteractor.call(params: params, user: user)

        expect(result.edition.status).to be_draft
      end
    end
  end
end
