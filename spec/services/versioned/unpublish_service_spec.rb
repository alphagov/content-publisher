# frozen_string_literal: true

RSpec.describe Versioned::UnpublishService do
  include AssetManagerHelper

  let(:edition) { create(:versioned_edition, :published) }
  let(:edition_with_image) do
    create(:versioned_edition, :published, lead_image_revision: image_revision)
  end
  let(:image_revision) do
    create(:versioned_image_revision, :on_asset_manager, state: :live)
  end

  before { stub_any_publishing_api_unpublish }

  describe "#retire" do
    let(:explanatory_note) { "The document is out of date" }

    it "withdraws an edition in publishing-api with an explanatory note" do
      request = stub_publishing_api_unpublish(edition.content_id,
                                              body: { type: "withdrawal",
                                                      explanation: explanatory_note,
                                                      locale: edition.locale })
      Versioned::UnpublishService.new.retire(edition, explanatory_note)

      expect(request).to have_been_requested
    end

    it "does not delete assets for retired editions" do
      delete_request = stub_asset_manager_deletes_assets
      Versioned::UnpublishService.new.retire(edition_with_image, explanatory_note)

      expect(delete_request).not_to have_been_requested
    end

    it "adds an entry in the timeline of the document" do
      Versioned::UnpublishService.new.retire(edition, explanatory_note)

      expect(edition.timeline_entries.first.entry_type).to eq("retired")
    end

    it "updates the edition status" do
      Versioned::UnpublishService.new.retire(edition, explanatory_note)
      edition.reload

      expect(edition.status).to be_retired
      expect(edition.status.details.explanatory_note).to eq(explanatory_note)
    end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        expect { Versioned::UnpublishService.new.retire(draft_edition, explanatory_note) }
          .to raise_error RuntimeError, "attempted to unpublish an edition other than the live edition"
      end
    end

    context "when there is a live and a draft edition" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        live_edition = create(:versioned_edition,
                              :published,
                              current: false,
                              document: draft_edition.document)

        expect { Versioned::UnpublishService.new.retire(live_edition, explanatory_note) }
          .to raise_error RuntimeError, "Publishing API does not support unpublishing while there is a draft"
      end
    end
  end

  describe "#remove" do
    it "removes an edition" do
      request = stub_publishing_api_unpublish(edition.content_id,
                                              body: { type: "gone",
                                                      locale: edition.locale })
      Versioned::UnpublishService.new.remove(edition)

      expect(request).to have_been_requested
    end

    it "deletes assets associated with removed editions" do
      delete_request = stub_asset_manager_deletes_assets

      Versioned::UnpublishService.new.remove(edition_with_image)
      expect(delete_request).to have_been_requested.at_least_once
    end

    it "accepts an optional explanatory note" do
      explanatory_note = "The reason document has been removed"
      request = stub_publishing_api_unpublish(edition.content_id,
                                              body: { type: "gone",
                                                      explanation: explanatory_note,
                                                      locale: edition.locale })

      Versioned::UnpublishService.new.remove(edition,
                                             explanatory_note: explanatory_note)

      expect(request).to have_been_requested
    end

    it "accepts an optional alternative path" do
      alternative_path = "/look-here-instead"
      request = stub_publishing_api_unpublish(edition.content_id,
                                              body: { type: "gone",
                                                      alternative_path: alternative_path,
                                                      locale: edition.locale })

      Versioned::UnpublishService.new.remove(edition,
                                             alternative_path: alternative_path)

      expect(request).to have_been_requested
    end

    it "adds an entry in the timeline of the document" do
      explanatory_note = "The reason document has been removed"
      alternative_path = "/look-here-instead"

      Versioned::UnpublishService.new.remove(edition,
                                             explanatory_note: explanatory_note,
                                             alternative_path: alternative_path)

      timeline_entry = edition.document.timeline_entries.first
      expect(timeline_entry.entry_type).to eq("removed")
      expect(timeline_entry.details.explanatory_note).to eq(explanatory_note)
      expect(timeline_entry.details.alternative_path).to eq(alternative_path)
      expect(timeline_entry.details.redirect).to be_falsey
    end

    it "updates the edition status" do
      Versioned::UnpublishService.new.remove(edition)
      edition.reload

      expect(edition.status).to be_removed
      expect(edition.status.details.redirect).to be false
    end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        expect { Versioned::UnpublishService.new.remove(draft_edition) }
          .to raise_error RuntimeError, "attempted to unpublish an edition other than the live edition"
      end
    end

    context "when there is a live and a draft edition" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        live_edition = create(:versioned_edition,
                              :published,
                              current: false,
                              document: draft_edition.document)

        expect { Versioned::UnpublishService.new.remove(live_edition) }
          .to raise_error RuntimeError, "Publishing API does not support unpublishing while there is a draft"
      end
    end
  end

  describe "#remove_and_redirect" do
    let(:redirect_path) { "/redirect-path" }

    it "removes editions with a redirect" do
      unpublish = stub_publishing_api_unpublish(edition.content_id,
                                                body: { type: "redirect",
                                                        alternative_path: redirect_path,
                                                        locale: edition.locale })
      Versioned::UnpublishService.new.remove_and_redirect(edition, redirect_path)

      expect(unpublish).to have_been_requested
    end

    it "deletes assets associated with redirected editions" do
      delete_request = stub_asset_manager_deletes_assets

      Versioned::UnpublishService.new.remove_and_redirect(edition_with_image,
                                                          redirect_path)
      expect(delete_request).to have_been_requested.at_least_once
    end

    it "accepts an optional explanatory note" do
      explanatory_note = "The reason document has been removed"
      unpublish = stub_publishing_api_unpublish(edition.content_id,
                                                body: { type: "redirect",
                                                        alternative_path: redirect_path,
                                                        explanation: explanatory_note,
                                                        locale: edition.locale })

      Versioned::UnpublishService.new.remove_and_redirect(edition,
                                                          redirect_path,
                                                          explanatory_note: explanatory_note)

      expect(unpublish).to have_been_requested
    end

    it "adds an entry in the timeline of the document" do
      explanatory_note = "The reason document has been removed"

      Versioned::UnpublishService.new.remove_and_redirect(
        edition,
        redirect_path,
        explanatory_note: explanatory_note,
      )

      timeline_entry = edition.document.timeline_entries.first
      expect(timeline_entry.entry_type).to eq("removed")
      expect(timeline_entry.details.explanatory_note).to eq(explanatory_note)
      expect(timeline_entry.details.alternative_path).to eq(redirect_path)
      expect(timeline_entry.details.redirect).to be true
    end

    it "updates the edition status" do
      Versioned::UnpublishService.new.remove_and_redirect(edition, redirect_path)
      edition.reload

      expect(edition.status).to be_removed
      expect(edition.status.details.redirect).to be true
    end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        expect { Versioned::UnpublishService.new.remove_and_redirect(draft_edition, redirect_path) }
          .to raise_error RuntimeError, "attempted to unpublish an edition other than the live edition"
      end
    end

    context "when there is a live and a draft edition" do
      it "raises an error" do
        draft_edition = create(:versioned_edition)
        live_edition = create(:versioned_edition,
                              :published,
                              current: false,
                              document: draft_edition.document)

        expect { Versioned::UnpublishService.new.remove_and_redirect(live_edition, redirect_path) }
          .to raise_error RuntimeError, "Publishing API does not support unpublishing while there is a draft"
      end
    end
  end
end
