# frozen_string_literal: true

RSpec.describe PublishService do
  describe "#publish" do
    context "when there is no live edition" do
      let(:edition) { create(:edition, :publishable) }
      let!(:publish_request) do
        stub_publishing_api_publish(edition.content_id,
                                    update_type: nil,
                                    locale: edition.locale)
      end

      it "publishes the current_edition" do
        PublishService.new(edition.document)
                      .publish(user: create(:user), with_review: true)
        edition.reload
        expect(publish_request).to have_been_requested
        expect(edition.document.live_edition).to eq(edition)
        expect(edition).to be_published
        expect(edition).to be_live
      end

      it "can specify if edition is reviewed" do
        PublishService.new(edition.document)
                      .publish(user: create(:user), with_review: false)
        edition.reload
        expect(publish_request).to have_been_requested
        expect(edition).to be_published_but_needs_2i
      end
    end

    context "when there is a live edition" do
      it "supersedes the live edition" do
        document = create(:document, :with_current_and_live_editions)
        current_edition = document.current_edition
        live_edition = document.live_edition
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)

        PublishService.new(document)
                      .publish(user: create(:user), with_review: true)

        document.reload
        expect(document.live_edition).to eq(current_edition)
        expect(live_edition).to be_superseded
      end
    end

    context "when the current edition has images" do
      let(:image_revision) { create(:image_revision, :on_asset_manager) }
      let!(:edition) do
        create(:edition, :publishable, image_revisions: [image_revision])
      end

      before do
        stub_publishing_api_publish(edition.content_id,
                                    update_type: nil,
                                    locale: edition.locale)

        stub_asset_manager_updates_any_asset
      end

      it "makes the image assets live" do
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[draft])

        PublishService.new(edition.document)
                      .publish(user: create(:user), with_review: true)

        image_revision.reload
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[live])
      end
    end

    context "when the live edition has live images that the current edition hasn't got" do
      let(:image_revision_to_remove) do
        create(:image_revision, :on_asset_manager, state: :live)
      end

      let(:image_revision_to_keep) do
        create(:image_revision, :on_asset_manager, state: :live)
      end

      let(:document) { create(:document) }

      let!(:live_edition) do
        create(:edition,
               :published,
               image_revisions: [image_revision_to_remove, image_revision_to_keep],
               current: false,
               document: document)
      end

      let!(:current_edition) do
        create(:edition,
               :publishable,
               image_revisions: [image_revision_to_keep],
               document: document)
      end

      before do
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)
      end

      it "removes ones not used by the current edition" do
        delete_request = stub_asset_manager_deletes_any_asset

        PublishService.new(document)
                      .publish(user: create(:user), with_review: true)

        image_revision_to_remove.reload
        expect(image_revision_to_remove.assets.map(&:state).uniq).to eq(%w[absent])
        expect(delete_request).to have_been_requested.at_least_once
      end

      it "keeps images used by the current edition" do
        stub_asset_manager_deletes_any_asset
        PublishService.new(document)
                      .publish(user: create(:user), with_review: true)

        image_revision_to_keep.reload
        expect(image_revision_to_keep.assets.map(&:state).uniq).to eq(%w[live])
      end
    end

    context "when the current edition has an updated version of the live editions" do
      let(:old_image_revision) do
        create(:image_revision, :on_asset_manager, state: :live)
      end

      let(:new_image_revision) do
        create(:image_revision, :on_asset_manager, image: old_image_revision.image)
      end

      let(:document) { create(:document) }

      let!(:live_edition) do
        create(:edition,
               :published,
               image_revisions: [old_image_revision],
               current: false,
               document: document)
      end

      let!(:current_edition) do
        create(:edition,
               :publishable,
               image_revisions: [new_image_revision],
               document: document)
      end

      before do
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)
        stub_asset_manager_updates_any_asset
      end

      it "supersedes the old files" do
        PublishService.new(document)
                      .publish(user: create(:user), with_review: true)

        old_image_revision.reload
        expect(old_image_revision.assets.map(&:state).uniq).to eq(%w[superseded])
      end
    end
  end
end
