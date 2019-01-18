# frozen_string_literal: true

RSpec.describe Versioned::DeleteDraftService do
  include AssetManagerHelper

  let(:user) { create :user }

  describe "#delete" do
    it "raises an exception if there is not a current edition" do
      document = create :versioned_document

      expect { Versioned::DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a document without a current edition"
    end

    it "raises an exception if the current edition is live" do
      document = create :versioned_document, :with_live_edition

      expect { Versioned::DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a live document"
    end

    it "attempts to delete the document preview" do
      document = create :versioned_document, :with_current_edition
      request = stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(request).to have_been_requested
    end

    it "attempts to delete the assets from asset manager" do
      image_revision = create :versioned_image_revision, :on_asset_manager
      edition = create :versioned_edition, lead_image_revision: image_revision

      stub_publishing_api_discard_draft(edition.content_id)
      delete_request = stub_asset_manager_deletes_assets

      Versioned::DeleteDraftService.new(edition.document, user).delete

      expect(delete_request).to have_been_requested.at_least_once
      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
    end

    it "sets the current edition of the document to nil if there is no live edition" do
      document = create :versioned_document, :with_current_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    it "sets the current edition of the document to current_edition if there is a live edition" do
      document = create :versioned_document, :with_current_and_live_editions
      live_edition = document.live_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to eq(live_edition)
    end

    it "sets the status of the edition of the document to be discarded" do
      document = create :versioned_document, :with_current_edition
      edition = document.current_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(edition.status).to be_discarded
    end

    it "copes if the document preview does not exist" do
      document = create :versioned_document, :with_current_edition
      stub_any_publishing_api_call_to_return_not_found
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    it "copes if an asset is not in Asset Manager" do
      image_revision = create :versioned_image_revision
      edition = create :versioned_edition, lead_image_revision: image_revision

      stub_publishing_api_discard_draft(edition.content_id)
      Versioned::DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded

      expect(image_revision.reload.assets.map(&:state).uniq).to eq(%w[absent])
    end

    it "copes if an asset is not in Asset Manager" do
      image_revision = create :versioned_image_revision, :on_asset_manager
      edition = create :versioned_edition, lead_image_revision: image_revision

      image_revision.assets.map do |asset|
        asset_manager_does_not_have_an_asset(asset.asset_manager_id)
      end

      stub_publishing_api_discard_draft(edition.content_id)
      Versioned::DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
    end

    it "raises an error when the Pubishing API is down" do
      document = create :versioned_document, :with_current_edition
      publishing_api_isnt_available
      expect { Versioned::DeleteDraftService.new(document, user).delete }.to raise_error GdsApi::BaseError
    end

    it "raises an error when Asset Manager is down" do
      image_revision = create :versioned_image_revision, :on_asset_manager
      edition = create :versioned_edition, lead_image_revision: image_revision

      stub_asset_manager_down

      expect { Versioned::DeleteDraftService.new(edition.document, user).delete }
        .to raise_error(GdsApi::BaseError)
      expect(edition.reload.revision_synced).to be false
    end
  end
end
