# frozen_string_literal: true

RSpec.describe DeleteDraftService do
  let(:user) { create :user }

  describe "#delete" do
    it "raises an exception if there is not a current edition" do
      document = create :document

      expect { DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a document without a current edition"
    end

    it "raises an exception if the current edition is live" do
      document = create :document, :with_live_edition

      expect { DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a live document"
    end

    it "attempts to delete the document preview" do
      document = create :document, :with_current_edition
      stub_publishing_api_unreserve_path(document.current_edition.base_path)
      request = stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document, user).delete
      expect(request).to have_been_requested
    end

    it "attempts to delete the assets from asset manager" do
      image_revision = create :image_revision, :on_asset_manager
      edition = create :edition, lead_image_revision: image_revision

      stub_publishing_api_discard_draft(edition.content_id)
      stub_publishing_api_unreserve_path(edition.base_path)
      delete_request = stub_asset_manager_deletes_any_asset

      DeleteDraftService.new(edition.document, user).delete

      expect(delete_request).to have_been_requested.at_least_once
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
    end

    it "attempts to delete path reservations for a first draft" do
      edition = create :edition
      previous_revision = create :revision
      edition.revisions << previous_revision

      stub_publishing_api_discard_draft(edition.content_id)

      unreserve_request1 = stub_publishing_api_unreserve_path(
        edition.base_path,
        PublishingApiPayload::PUBLISHING_APP,
      )

      unreserve_request2 = stub_publishing_api_unreserve_path(
        previous_revision.base_path,
        PublishingApiPayload::PUBLISHING_APP,
      )

      DeleteDraftService.new(edition.document, user).delete

      expect(unreserve_request1).to have_been_requested
      expect(unreserve_request2).to have_been_requested
    end

    it "does not delete path reservations for published documents" do
      document = create :document, :with_current_and_live_editions
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to eq document.live_edition
    end

    it "sets the current edition of the document to nil if there is no live edition" do
      document = create :document, :with_current_edition
      stub_publishing_api_unreserve_path(document.current_edition.base_path)
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    it "sets the current edition of the document to current_edition if there is a live edition" do
      document = create :document, :with_current_and_live_editions
      live_edition = document.live_edition
      stub_publishing_api_unreserve_path(document.current_edition.base_path)
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to eq(live_edition)
    end

    it "sets the status of the edition of the document to be discarded" do
      document = create :document, :with_current_edition
      edition = document.current_edition
      stub_publishing_api_unreserve_path(document.current_edition.base_path)
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document, user).delete
      expect(edition.status).to be_discarded
    end

    it "copes if the document preview does not exist" do
      document = create :document, :with_current_edition
      stub_publishing_api_unreserve_path(document.current_edition.base_path)
      stub_any_publishing_api_call_to_return_not_found
      DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    it "copes if an asset is not in Asset Manager" do
      image_revision = create :image_revision
      edition = create :edition, lead_image_revision: image_revision

      stub_publishing_api_unreserve_path(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)
      DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
    end

    it "copes if the base path is not reserved" do
      edition = create :edition

      stub_publishing_api_unreserve_path_not_found(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)
      DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
    end

    it "copes if the base path is not valid" do
      edition = create :edition, base_path: nil

      stub_publishing_api_discard_draft(edition.content_id)
      DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
    end

    it "removes assets if the asset is on Asset Manager" do
      image_revision = create :image_revision, :on_asset_manager
      edition = create :edition, lead_image_revision: image_revision

      image_revision.assets.map do |asset|
        stub_asset_manager_does_not_have_an_asset(asset.asset_manager_id)
      end

      stub_publishing_api_unreserve_path(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)
      DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
    end

    it "raises an error when a base path cannot be deleted" do
      edition = create :edition

      stub_publishing_api_discard_draft(edition.content_id)
      stub_publishing_api_unreserve_path_invalid(edition.base_path)

      expect { DeleteDraftService.new(edition.document, user).delete }
        .to raise_error(GdsApi::BaseError)

      expect(edition.reload.revision_synced?).to be true
    end

    it "raises an error when the Pubishing API is down" do
      edition = create :edition
      stub_publishing_api_isnt_available

      expect { DeleteDraftService.new(edition.document, user).delete }
        .to raise_error(GdsApi::BaseError)

      expect(edition.reload.revision_synced?).to be false
    end

    it "raises an error when Asset Manager is down" do
      image_revision = create :image_revision, :on_asset_manager
      edition = create :edition, lead_image_revision: image_revision

      stub_asset_manager_isnt_available

      expect { DeleteDraftService.new(edition.document, user).delete }
        .to raise_error(GdsApi::BaseError)

      expect(edition.reload.revision_synced?).to be false
    end
  end
end
