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

    describe "marks an edition as political" do
      it "sets system_political to true when the edition is identified as political" do
        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .with(edition)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: true))

        expect { EditEditionService.call(edition, user) }
          .to change { edition.system_political }
          .to(true)
      end

      it "sets system_political to false when the edition is not identified as political" do
        edition = build(:edition, system_political: true)

        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .with(edition)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: false))

        expect { EditEditionService.call(edition, user) }
          .to change { edition.system_political }
          .to(false)
      end
    end

    describe "associates the edition with a government" do
      it "sets the government for a backdated edition" do
        backdate = Time.zone.parse("2018-01-01")
        government = build(:government)
        edition = create(:edition, backdated_to: backdate)
        allow(Government).to receive(:for_date).with(edition.backdated_to)
                         .and_return(government)

        expect { EditEditionService.call(edition, user) }
          .to change { edition.government_id }
          .to(government.content_id)
      end

      it "sets the government for an edition of a published document" do
        publish_date = Time.zone.parse("2019-11-01")
        government = build(:government)
        allow(Government).to receive(:for_date).with(publish_date)
                         .and_return(government)
        edition = build(:edition, first_published_at: publish_date)

        expect { EditEditionService.call(edition, user) }
          .to change { edition.government_id }
          .to(government.content_id)
      end

      it "sets the government to nil when there isn't a government for the date" do
        publish_date = Time.zone.parse("2019-11-01")
        allow(Government).to receive(:for_date).with(publish_date)
                         .and_return(nil)
        edition = build(:edition, first_published_at: publish_date)

        expect { EditEditionService.call(edition, user) }
          .not_to change { edition.government_id }
          .from(nil)
      end

      it "sets the government to nil when an edition isn't backdated or the document published" do
        edition = build(:edition)

        expect { EditEditionService.call(edition, user) }
          .not_to change { edition.government_id }
          .from(nil)
      end
    end
  end
end
