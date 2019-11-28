# frozen_string_literal: true

RSpec.describe AssignEditionStatusService do
  include ActiveSupport::Testing::TimeHelpers

  describe ".call" do
    let(:edition) { build(:edition) }
    let(:user) { build(:user) }

    it "assigns a status attributed to a user" do
      AssignEditionStatusService.call(edition, user, :submitted_for_review)

      expect(edition.status).to be_submitted_for_review
      expect(edition.status.created_by).to eq(user)
    end

    it "does not save the edition" do
      AssignEditionStatusService.call(edition, user, :submitted_for_review)

      expect(edition).to be_new_record
    end

    it "updates last edited" do
      freeze_time do
        edition = build(:edition, last_edited_at: 3.weeks.ago)

        expect { AssignEditionStatusService.call(edition, user, :submitted_for_review) }
          .to change { edition.last_edited_by }.to(user)
          .and change { edition.last_edited_at }.to(Time.current)
      end
    end

    it "preserves last edited when specified" do
      freeze_time do
        edition = build(:edition, last_edited_at: 3.weeks.ago)
        AssignEditionStatusService.call(edition,
                                        user,
                                        :submitted_for_review,
                                        update_last_edited: false)

        expect(edition.last_edited_at).not_to eq(Time.current)
        expect(edition.last_edited_at).to eq(3.weeks.ago)
        expect(edition.last_edited_by).not_to eq(user)
      end
    end

    it "can set details on the status" do
      removal = build(:removal)
      AssignEditionStatusService.call(edition,
                                      user,
                                      :removed,
                                      status_details: removal)

      expect(edition.status.details).to eq(removal)
    end
  end
end
