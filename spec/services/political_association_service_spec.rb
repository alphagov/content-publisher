# frozen_string_literal: true

RSpec.describe PoliticalAssociationService do
  include ActiveSupport::Testing::TimeHelpers

  describe ".call" do
    describe "associates an edition with a government" do
      it "sets the government for a backdated edition" do
        backdate = Time.zone.parse("2018-01-01")
        government = build(:government)
        edition = create(:edition, backdated_to: backdate)
        allow(Government).to receive(:for_date).with(edition.backdated_to)
                         .and_return(government)

        expect { PoliticalAssociationService.call(edition) }
          .to change { edition.reload.government_id }
          .to(government.content_id)
      end

      it "sets the government for an edition of a published document" do
        publish_date = Time.zone.parse("2019-11-01")
        government = build(:government)
        allow(Government).to receive(:for_date).with(publish_date)
                         .and_return(government)
        edition = create(:edition, :published, first_published_at: publish_date)

        expect { PoliticalAssociationService.call(edition) }
          .to change { edition.reload.government_id }
          .to(government.content_id)
      end

      it "sets the government to nil when an edition isn't backdated or the document published" do
        edition = create(:edition)

        expect { PoliticalAssociationService.call(edition) }
          .not_to change { edition.reload.government_id }
          .from(nil)
      end

      it "can set the government to a provided one when an edition isn't backdated or the document published" do
        edition = create(:edition)
        government = build(:government)

        expect { PoliticalAssociationService.call(edition, fallback_government: government) }
          .to change { edition.reload.government_id }
          .to(government.content_id)
      end

      it "doesn't use the fallback government when no government exists for the date" do
        backdate = Time.zone.parse("2018-01-01")
        edition = create(:edition, backdated_to: backdate)
        fallback_government = build(:government)
        allow(Government).to receive(:for_date).with(edition.backdated_to)
                         .and_return(nil)

        expect { PoliticalAssociationService.call(edition, fallback_government: fallback_government) }
          .not_to change { edition.reload.government_id }
          .from(nil)
      end
    end

    describe "marks an edition as political" do
      it "sets system_political to true when the edition is identified as political" do
        edition = create(:edition, system_political: false)
        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .with(edition)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: true))

        expect { PoliticalAssociationService.call(edition) }
          .to change { edition.reload.system_political }
          .to(true)
      end

      it "sets system_political to false when the edition is not identified as political" do
        edition = create(:edition, system_political: true)
        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .with(edition)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: false))

        expect { PoliticalAssociationService.call(edition) }
          .to change { edition.reload.system_political }
          .to(false)
      end
    end

    describe "updating revision_synced value" do
      before do
        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: true))
      end

      it "sets revision_synced to false when values change" do
        edition = create(:edition,
                         system_political: false,
                         revision_synced: true)

        expect { PoliticalAssociationService.call(edition) }
          .to change { edition.reload.revision_synced }
          .to(false)
      end

      it "doesn't update revision_synced when the edition is not modified" do
        edition = create(:edition,
                         system_political: true,
                         revision_synced: true)

        expect { PoliticalAssociationService.call(edition) }
          .not_to(change { edition.reload.revision_synced })
      end
    end
  end
end
