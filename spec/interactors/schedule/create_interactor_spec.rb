# frozen_string_literal: true

RSpec.describe Schedule::CreateInteractor do
  describe ".call" do
    before { stub_any_publishing_api_put_intent }
    let(:edition) { create(:edition, :schedulable) }
    let(:user) { build(:user) }

    def build_params(document: edition.document, review_status: "reviewed")
      ActionController::Parameters.new(document: document.to_param,
                                       review_status: review_status)
    end

    it "succeeds with default paramaters" do
      result = Schedule::CreateInteractor.call(params: build_params, user: user)
      expect(result).to be_success
    end

    it "delegates to SchedulePublishService to schedule the edition for publishing" do
      publish_time = 3.days.from_now.beginning_of_day
      edition = create(:edition, :schedulable, proposed_publish_time: publish_time)

      expect(SchedulePublishService)
        .to receive(:call) do |schedule_edition, schedule_user, new_scheduling|
          expect(schedule_edition).to eq(edition)
          expect(schedule_user).to eq(user)
          expect(new_scheduling.reviewed).to be(false)
          expect(new_scheduling.publish_time).to eq(publish_time)
        end

      params = build_params(document: edition.document,
                            review_status: "not_reviewed")
      Schedule::CreateInteractor.call(params: params, user: user)
    end

    it "creates a timeline entry" do
      expect { Schedule::CreateInteractor.call(params: build_params, user: user) }
        .to change { TimelineEntry.where(entry_type: :scheduled).count }
        .by(1)
    end

    it "raises an error when the edition isn't editable" do
      params = build_params(document: create(:edition, :published).document)
      expect { Schedule::CreateInteractor.call(params: params, user: user) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "raises an error when the edition hasn't got a proposed publish time" do
      edition = create(:edition, proposed_publish_time: nil)
      params = build_params(document: edition.document)
      expect { Schedule::CreateInteractor.call(params: params, user: user) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "raises an error when the edition isn't publishable" do
      edition = create(:edition,
                       :not_publishable,
                       proposed_publish_time: Time.zone.tomorrow)
      params = build_params(document: edition.document)
      expect { Schedule::CreateInteractor.call(params: params, user: user) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "fails with an issue when a review status isn't set" do
      result = Schedule::CreateInteractor.call(
        params: build_params.merge(review_status: nil),
        user: user,
      )
      expect(result).to be_failure
      expect(result.issues).to have_issue(:schedule_review_status, :not_selected)
    end

    it "fails with an API error when SchedulePublishService raises a GdsApi Error" do
      stub_publishing_api_isnt_available
      result = Schedule::CreateInteractor.call(params: build_params, user: user)

      expect(result).to be_failure
      expect(result.api_error).to be(true)
    end
  end
end
