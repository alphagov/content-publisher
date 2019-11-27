# frozen_string_literal: true

RSpec.describe EditEditionService do
  include ActiveSupport::Testing::TimeHelpers

  describe ".call" do
    let(:edition) { build(:edition) }
    let(:user) { build(:user) }

    it "assigns attributes to an edition" do
      revision = build(:revision)

      expect { EditEditionService.call(edition, user, revision: revision) }
        .to change { edition.revision }.to(revision)
    end

    it "does not save the edition" do
      EditEditionService.call(edition, user, {})

      expect(edition).to be_new_record
    end

    it "updates who edited it and when" do
      freeze_time do
        edition = build(:edition, last_edited_at: 3.weeks.ago)

        expect { EditEditionService.call(edition, user) }
          .to change { edition.last_edited_by }.to(user)
          .and change { edition.last_edited_at }.to(Time.current)
      end
    end

    it "raises an error if a live edition is edited" do
      live_edition = build(:edition, live: true)

      expect { EditEditionService.call(live_edition, user) }
        .to raise_error("cannot edit a live edition")
    end
  end
end
