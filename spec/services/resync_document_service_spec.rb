# frozen_string_literal: true

RSpec.describe ResyncDocumentService do
  include ActiveJob::TestHelper

  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
      stub_any_publishing_api_put_intent
      stub_any_publishing_api_path_reservation
      populate_default_government_bulk_data
    end

    it "reserves base paths" do
      document = create(:document, :with_current_and_live_editions)

      reserve_path_params = {
        publishing_app: "content-publisher",
        override_existing: true,
      }

      draft_request = stub_publishing_api_path_reservation(
        document.current_edition.base_path,
        reserve_path_params,
      )
      live_request = stub_publishing_api_path_reservation(
        document.live_edition.base_path,
        reserve_path_params,
      )

      ResyncDocumentService.call(document)

      expect(draft_request).to have_been_requested
      expect(live_request).to have_been_requested
    end

    it "updates the system_political value of editions" do
      document = create(:document, :with_current_and_live_editions)

      expect(PoliticalEditionIdentifier)
        .to receive(:new)
        .twice
        .and_return(instance_double(PoliticalEditionIdentifier, political?: true))

      expect { ResyncDocumentService.call(document) }
        .to change { document.live_edition.system_political }.to(true)
        .and change { document.current_edition.system_political }.to(true)
    end

    it "updates the government_id of editions" do
      document = create(:document, :with_current_and_live_editions)
      government = build(:government)
      populate_government_bulk_data(government)

      expect { ResyncDocumentService.call(document) }
        .to change { document.live_edition.government_id }.to(government.content_id)
        .and change { document.current_edition.government_id }.to(government.content_id)
    end

    context "when there is no live edition" do
      let(:edition) { create(:edition) }

      it "doesn't publish the edition" do
        expect(FailsafeDraftPreviewService).to receive(:call).with(edition)
        expect(GdsApi.publishing_api).not_to receive(:publish)
        ResyncDocumentService.call(edition.document)
      end
    end

    context "when the current edition is live" do
      let(:edition) { create(:edition, :published) }

      it "avoids synchronising the edition twice" do
        expect(PreviewDraftEditionService).to receive(:call).once
        ResyncDocumentService.call(edition.document)
      end

      it "re-publishes the live edition" do
        expect(PreviewDraftEditionService).to receive(:call)
                              .with(edition, republish: true)
                              .and_call_original

        request = stub_publishing_api_publish(
          edition.content_id,
          update_type: nil,
          locale: edition.locale,
        )
        ResyncDocumentService.call(edition.document)

        expect(request).to have_been_requested
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetsService)
          .to receive(:call).once.with(edition, nil)

        ResyncDocumentService.call(edition.document)
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
        ResyncDocumentService.call(edition.document)

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
          ResyncDocumentService.call(edition.document)

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
          ResyncDocumentService.call(edition.document)

          expect(request).to have_been_requested
        end
      end

      context "when the current edition has been scheduled for publication" do
        let(:edition) { create(:edition, :scheduled) }

        before do
          allow(SchedulePublishService::Payload)
            .to receive(:new)
            .and_return(instance_double(SchedulePublishService::Payload, intent_payload: "payload"))
        end

        it "notifies the publishing-api of the intent to publish" do
          request = stub_publishing_api_put_intent(edition.base_path, '"payload"')

          expect(SchedulePublishService::Payload)
            .to receive(:new)
            .with(edition)

          ResyncDocumentService.call(edition.document)
          expect(request).to have_been_requested
        end

        it "schedules the edition to publish" do
          ResyncDocumentService.call(edition.document)
          expect(ScheduledPublishingJob)
            .to have_been_enqueued
            .with(edition.id)
            .at(edition.status.details.publish_time)
        end
      end
    end
  end
end
