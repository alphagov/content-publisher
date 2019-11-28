# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
    end

    context "when there is no live edition" do
      let(:document) { create(:document, :with_current_edition) }

      it "synchronises the current edition, but does not publish" do
        expect_path_reserved(document.current_edition.base_path)
        expect(PreviewService).to receive(:call).with(document.current_edition)
        expect(GdsApi.publishing_api_v2).not_to receive(:publish)
        expect(GdsApi.publishing_api_v2).not_to receive(:republish)
        ResyncService.call(document)
      end

      # it "retains 2i review status" do
      #   PublishService.call(edition, user, with_review: false)
      #   expect(edition).to be_published_but_needs_2i
      # end

      # it "retains the access limit" do
      #   edition = create(:edition, :access_limited)
      #   PublishService.call(edition, user, with_review: true)
      #   expect(edition.access_limit).to be_present
      #   expect(edition.access_limit).to be_tagged_organisations
      # end
    end

    context "when the current edition is live" do
      let(:document) { create(:document, :with_live_edition) }

      it "re-publishes the current_edition" do
        GdsApi.stub_chain(:publishing_api_v2, :put_content)
        GdsApi.stub_chain(:publishing_api_v2, :publish)
        expect_path_reserved(document.live_edition.base_path)
        expect(GdsApi.publishing_api_v2).to receive(:put_content).once.with(document.content_id, hash_including(update_type: "republish")).ordered
        expect(GdsApi.publishing_api_v2).to receive(:publish).once.with(document.content_id, nil, hash_including(:locale)).ordered
        ResyncService.call(document)

        # @TODO - test that PublishAssetService is called
      end

      # it "retains 2i review status" do
      #   PublishService.call(edition, user, with_review: false)
      #   expect(edition).to be_published_but_needs_2i
      # end

      # it "calls the PublishAssetService" do
      #   document = create(:document, :with_current_and_live_editions)
      #   current_edition = document.current_edition
      #   expect(PublishAssetService).to receive(:call)
      #   PublishService.call(current_edition, user, with_review: true)
      # end
    end

    context "when there are both live and current editions" do
      let(:document) { create(:document, :with_current_and_live_editions) }

      it "re-publishes the live edition before synchronising the current edition without publishing it" do
        GdsApi.stub_chain(:publishing_api_v2, :put_content)

        # LIVE EDITION
        expect_path_reserved(document.live_edition.base_path)
        expect(GdsApi.publishing_api_v2).to receive(:put_content).once.with(document.content_id, hash_including(update_type: "republish")).ordered
        expect(GdsApi.publishing_api_v2).to receive(:publish).once.with(document.content_id, nil, hash_including(:locale)).ordered

        # CURRENT EDITION
        expect_path_reserved(document.current_edition.base_path)
        # @TODO - test that PublishAssetService is called for live edition next
        expect(PreviewService).to receive(:call).with(document.current_edition).ordered
        ResyncService.call(document)
      end
    end
  end

  def expect_path_reserved(base_path)
    GdsApi.stub_chain(:publishing_api_v2, :put_path)
    expect(GdsApi.publishing_api_v2).to receive(:put_path).once.with(
      base_path,
      hash_including(publishing_app: "content-publisher", override_existing: true),
    ).ordered
  end
end
