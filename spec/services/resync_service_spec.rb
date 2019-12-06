# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
    end

    context "when there is no live edition" do
      let(:document) { create(:document, :with_current_edition) }

      it "it does not publish the edition" do
        expect(FailsafePreviewService).to receive(:call).with(document.current_edition)
        expect(GdsApi.publishing_api_v2).not_to receive(:publish)
        ResyncService.call(document)
      end
    end

    context "when the current edition is live" do
      let(:document) { create(:document, :with_live_edition) }

      it "avoids synchronising the edition twice" do
        expect(PreviewService).to receive(:call).once
        ResyncService.call(document)
      end

      it "re-publishes the live edition" do
        expect(PreviewService)
          .to receive(:call)
          .with(
            document.current_edition,
            republish: true,
          )
          .and_call_original

        request = stub_publishing_api_publish(
          document.content_id,
          update_type: nil,
          locale: document.locale,
        )
        ResyncService.call(document)

        expect(request).to have_been_requested
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetService).to receive(:call).once.
          with(document.live_edition, nil)
        ResyncService.call(document)
      end
    end

    context "when the live edition is withdrawn" do
      let(:edition) { create(:edition, :withdrawn) }
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
      end

      it "withdraws the edition" do
        withdraw_params = {
          type: "withdrawal",
          explanation: explanation,
          locale: edition.locale,
          unpublished_at: edition.status.details.withdrawn_at,
          allow_draft: true,
        }

        expect(GovspeakDocument)
          .to receive(:new)
          .with(edition.status.details.public_explanation, edition)
          .and_return(instance_double(GovspeakDocument, payload_html: explanation))

        request = stub_publishing_api_unpublish(edition.content_id, body: withdraw_params)
        ResyncService.call(edition.document)

        expect(request).to have_been_requested
      end
    end

    context "when the live edition has been removed" do
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
      end

      context "when the live edition is removed with a redirect" do
        let(:removal) do
          build(
            :removal,
            redirect: true,
            alternative_path: "/foo/bar",
            explanatory_note: explanation,
          )
        end

        let(:edition) { create(:edition, :removed, removal: removal) }

        it "removes and redirects the edition" do
          remove_params = {
            type: "redirect",
            explanation: explanation,
            alternative_path: removal.alternative_path,
            locale: edition.locale,
            unpublished_at: removal.created_at,
            allow_draft: true,
          }

          request = stub_publishing_api_unpublish(edition.content_id, body: remove_params)
          ResyncService.call(edition.document)

          expect(request).to have_been_requested
        end
      end

      context "when the live edition is removed without a redirect" do
        let(:edition) { create(:edition, :removed) }

        it "removes the edition" do
          remove_params = {
            type: "gone",
            locale: edition.locale,
            unpublished_at: edition.status.details.created_at,
            allow_draft: true,
          }

          request = stub_publishing_api_unpublish(edition.content_id, body: remove_params)
          ResyncService.call(edition.document)

          expect(request).to have_been_requested
        end
      end
    end
  end
end
