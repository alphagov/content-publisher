RSpec.describe DeleteDraftEditionService do
  let(:user) { create(:user) }

  describe ".call" do
    before do
      stub_any_publishing_api_discard_draft
      stub_any_publishing_api_unreserve_path
    end

    describe "invalid edition" do
      it "raises an error when the edition isn't current" do
        edition = create(:edition, current: false)

        expect { described_class.call(edition, user) }
          .to raise_error("Only current editions can be deleted")
      end

      it "raises an exception if the current edition is live" do
        edition = create(:edition, live: true)

        expect { described_class.call(edition, user) }
          .to raise_error("Trying to delete a live edition")
      end
    end

    describe "changing edition status" do
      it "changes the editions current flag" do
        edition = create(:edition)
        expect { described_class.call(edition, user) }
          .to change { edition.current? }.to(false)
      end

      it "sets a live edition to be current after a draft is discarded" do
        document = create(:document, :with_current_and_live_editions)
        live_edition = document.live_edition
        expect { described_class.call(document.current_edition, user) }
          .to change { document.current_edition }.to(live_edition)
      end

      it "sets the status of the edition to discarded" do
        edition = create(:edition)
        expect { described_class.call(edition, user) }
          .to change { edition.discarded? }.to(true)
      end
    end

    describe "Publishing API communication" do
      it "discards the draft from the Publishing API" do
        edition = create(:edition)
        request = stub_publishing_api_discard_draft(edition.content_id)
        described_class.call(edition, user)
        expect(request).to have_been_requested
      end

      it "attempts to delete path reservations for a first draft" do
        edition = create(:edition)
        previous_revision = create(:revision)
        edition.revisions << previous_revision

        unreserve_request1 = stub_publishing_api_unreserve_path(
          edition.base_path,
          PreviewDraftEditionService::Payload::PUBLISHING_APP,
        )

        unreserve_request2 = stub_publishing_api_unreserve_path(
          previous_revision.base_path,
          PreviewDraftEditionService::Payload::PUBLISHING_APP,
        )

        described_class.call(edition, user)

        expect(unreserve_request1).to have_been_requested
        expect(unreserve_request2).to have_been_requested
      end

      it "does not delete path reservations for published documents" do
        document = create(:document, :with_current_and_live_editions)
        unreserve_request = stub_publishing_api_unreserve_path(
          document.current_edition.base_path,
          PreviewDraftEditionService::Payload::PUBLISHING_APP,
        )

        described_class.call(document.current_edition, user)
        expect(unreserve_request).not_to have_been_requested
      end


      it "copes if the document preview does not exist" do
        edition = create(:edition)
        stub_any_publishing_api_discard_draft.to_return(status: 404)
        described_class.call(edition, user)
        expect(edition).to be_discarded
      end

      it "copes if the publishing API has a live but not draft edition" do
        edition = create(:edition)
        discard_draft_error = {
          error: {
            code: 422,
            message: "There is not a draft edition of this document to discard",
          },
        }
        stub_any_publishing_api_discard_draft
          .to_return(status: 422, body: discard_draft_error.to_json)

        described_class.call(edition, user)
        expect(edition).to be_discarded
      end

      it "doesn't capture all Publishing API unprocessable entity issues" do
        edition = create(:edition)
        discard_draft_error = {
          error: {
            code: 422,
            message: "New Publishing API problem",
          },
        }
        stub_any_publishing_api_discard_draft
          .to_return(status: 422, body: discard_draft_error.to_json)

        expect { described_class.call(edition, user) }
          .to raise_error(GdsApi::HTTPUnprocessableEntity)
      end

      it "copes if the base path is not reserved" do
        edition = create(:edition)

        stub_publishing_api_unreserve_path_not_found(edition.base_path)
        described_class.call(edition, user)

        expect(edition).to be_discarded
      end

      it "copes if the base path is not valid" do
        edition = create(:edition, base_path: nil)
        described_class.call(edition, user)
        expect(edition).to be_discarded
      end

      it "raises an error and marks an edition as not synced when an API error occurs during discarding" do
        edition = create(:edition)
        stub_publishing_api_isnt_available

        expect { described_class.call(edition, user) }
          .to raise_error(GdsApi::BaseError)

        expect(edition.revision_synced?).to be(false)
      end

      it "doesn't mark an edition as not synced when an API error occurs whilst unreserving paths" do
        edition = create(:edition)
        stub_publishing_api_unreserve_path_invalid(edition.base_path)

        expect { described_class.call(edition, user) }
          .to raise_error(GdsApi::BaseError)

        expect(edition.revision_synced?).to be(true)
      end
    end

    describe "Asset Manager communication" do
      it "attempts to delete the assets from asset manager" do
        image_revision = create(:image_revision, :on_asset_manager)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
        edition = create(:edition,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        delete_request = stub_asset_manager_deletes_any_asset

        described_class.call(edition, user)

        expect(delete_request).to have_been_requested.at_least_once
        expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.reload.asset).to be_absent
      end

      it "copes if an asset is not in Asset Manager" do
        image_revision = create(:image_revision, :on_asset_manager)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
        edition = create(:edition,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])
        stub_any_asset_manager_call.to_return(status: 404)

        described_class.call(edition, user)

        expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.reload.asset).to be_absent
      end

      it "raises an error and marks as an edition as not synced when Asset Manager is down" do
        image_revision = create(:image_revision, :on_asset_manager)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
        edition = create(:edition,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        stub_asset_manager_isnt_available

        expect { described_class.call(edition, user) }
          .to raise_error(GdsApi::BaseError)

        expect(edition.revision_synced?).to be(false)
      end
    end
  end
end
