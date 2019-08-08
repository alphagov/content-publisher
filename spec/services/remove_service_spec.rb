# frozen_string_literal: true

RSpec.describe RemoveService do
  describe "#call" do
    let(:edition) { create(:edition, :published) }

    before { stub_any_publishing_api_unpublish }

    it "calls the Publishing API unpublish method" do
      request = stub_publishing_api_unpublish(
        edition.content_id,
        body: hash_including(locale: edition.locale),
      )
      RemoveService.call(edition, build(:removal))
      expect(request).to have_been_requested
    end

    it "creates a timeline entry" do
      removal = build(:removal)

      expect { RemoveService.call(edition, removal) }
        .to change { TimelineEntry.count }
        .by(1)

      timeline_entry = edition.timeline_entries.first
      expect(timeline_entry.entry_type).to eq("removed")
      expect(timeline_entry.details).to eq(removal)
    end

    it "updates the edition status" do
      removal = build(:removal)

      expect { RemoveService.call(edition, removal) }
        .to change { edition.reload.state }
        .to("removed")

      expect(edition.status.details).to eq(removal)
    end

    context "when the removal is a redirect" do
      it "unpublishes in the Publishing API with a type of redirect" do
        removal = build(:removal,
                        redirect: true,
                        alternative_path: "/path",
                        explanatory_note: "explanation")

        request = stub_publishing_api_unpublish(
          edition.content_id,
          body: {
            alternative_path: "/path",
            explanation: "explanation",
            locale: edition.locale,
            type: "redirect",
          },
        )
        RemoveService.call(edition, removal)
        expect(request).to have_been_requested
      end
    end

    context "when the removal is not a redirect" do
      it "unpublishes in the Publishing API with a type of gone" do
        removal = build(:removal,
                        redirect: false,
                        alternative_path: "/path",
                        explanatory_note: "explanation")

        request = stub_publishing_api_unpublish(
          edition.content_id,
          body: {
            alternative_path: "/path",
            explanation: "explanation",
            locale: edition.locale,
            type: "gone",
          },
        )
        RemoveService.call(edition, removal)
        expect(request).to have_been_requested
      end
    end

    context "when Publishing API is down" do
      before { stub_publishing_api_isnt_available }

      it "doesn't change the editions state" do
        expect { RemoveService.call(edition, build(:removal)) }
          .to raise_error(GdsApi::BaseError)
        expect(edition.reload.state).to eq("published")
      end
    end

    context "when an edition has assets" do
      it "removes assets that aren't absent" do
        image_revision = create(:image_revision, :on_asset_manager, state: :live)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        delete_request = stub_asset_manager_deletes_any_asset

        RemoveService.call(edition, build(:removal))

        expect(delete_request).to have_been_requested.at_least_once
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.asset).to be_absent
      end

      it "copes with assets that 404" do
        image_revision = create(:image_revision, :on_asset_manager, state: :live)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        delete_request = stub_asset_manager_deletes_any_asset.to_return(status: 404)

        RemoveService.call(edition, build(:removal))

        expect(delete_request).to have_been_requested.at_least_once
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.asset).to be_absent
      end

      it "ignores assets that are absent" do
        image_revision = create(:image_revision, :on_asset_manager, state: :absent)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :absent)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        delete_request = stub_asset_manager_deletes_any_asset

        RemoveService.call(edition, build(:removal))

        expect(delete_request).not_to have_been_requested
      end
    end

    context "when an edition has assets and Asset Manager is down" do
      before { stub_asset_manager_isnt_available }

      it "removes the edition" do
        image_revision = create(:image_revision, :on_asset_manager)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        expect { RemoveService.call(edition, build(:removal)) }
          .to raise_error(GdsApi::BaseError)

        expect(edition.reload.state).to eq("removed")
      end
    end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:edition)
        expect { RemoveService.call(draft_edition, build(:removal)) }
          .to raise_error "attempted to remove an edition other than the live edition"
      end
    end

    context "when there is a live and a draft edition" do
      it "raises an error" do
        draft_edition = create(:edition)
        live_edition = create(:edition,
                              :published,
                              current: false,
                              document: draft_edition.document)

        expect { RemoveService.call(live_edition, build(:removal)) }
          .to raise_error "Publishing API does not support unpublishing while there is a draft"
      end
    end
  end
end
