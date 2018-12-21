# frozen_string_literal: true

RSpec.describe UnpublishService do
  describe "#retire" do
    let(:document) { create(:document) }
    let(:explanatory_note) { "The document is out of date" }
    let(:user) { create(:user) }

    it "withdraws a document in publishing-api with an explanatory note" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })
      UnpublishService.new.retire(document, explanatory_note, user)

      assert_publishing_api_unpublish(document.content_id, type: "withdrawal", explanation: explanatory_note, locale: document.locale)
    end

    it "sets the locale of the document if specified" do
      french_document = create(:document, locale: "fr")

      stub_publishing_api_unpublish(french_document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: french_document.locale })
      UnpublishService.new.retire(french_document, explanatory_note, user)

      assert_publishing_api_unpublish(french_document.content_id, type: "withdrawal", explanation: explanatory_note, locale: french_document.locale)
    end

    it "does not delete assets for retired documents" do
      asset = create(:image, :in_preview, document: document)
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })

      UnpublishService.new.retire(document, explanatory_note, user)

      assert_not_requested asset_manager_delete_asset(asset.asset_manager_id)
    end

    it "adds an entry in the timeline of the document" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })
      UnpublishService.new.retire(document, explanatory_note, user)

      expect(document.timeline_entries.first.entry_type).to eq("retired")
    end

    it "keeps track of the live state" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note, locale: document.locale })
      UnpublishService.new.retire(document, explanatory_note, user)
      document.reload

      expect(document.live_state).to eq("retired")
      expect(document.timeline_entries.first.retirement.explanatory_note).to eq(explanatory_note)
    end
  end

  describe "#remove" do
    let(:document) { create(:document) }

    it "removes a document" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", locale: document.locale })
      UnpublishService.new.remove(document)

      assert_publishing_api_unpublish(document.content_id, type: "gone", locale: document.locale)
    end

    it "deletes assets associated with removed documents" do
      asset = create(:image, :in_preview, document: document)
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", locale: document.locale })
      asset_manager_request = asset_manager_delete_asset(asset.asset_manager_id)

      UnpublishService.new.remove(document)

      assert_requested(asset_manager_request)
    end

    it "accepts an optional explanatory note" do
      explanatory_note = "The reason document has been removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", explanation: explanatory_note, locale: document.locale })

      UnpublishService.new.remove(document, explanatory_note: explanatory_note)

      assert_publishing_api_unpublish(document.content_id, type: "gone", explanation: explanatory_note, locale: document.locale)
    end

    it "accepts an optional alternative path" do
      alternative_path = "/look-here-instead"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", alternative_path: alternative_path, locale: document.locale })

      UnpublishService.new.remove(document, alternative_path: alternative_path)

      assert_publishing_api_unpublish(document.content_id, type: "gone", alternative_path: alternative_path, locale: document.locale)
    end

    it "sets the locale of the document if specified" do
      french_document = create(:document, locale: "fr")

      stub_publishing_api_unpublish(french_document.content_id, body: { type: "gone", locale: french_document.locale })
      UnpublishService.new.remove(french_document)

      assert_publishing_api_unpublish(french_document.content_id, type: "gone", locale: french_document.locale)
    end

    it "adds an entry in the timeline of the document" do
      explanatory_note = "The reason document has been removed"
      alternative_path = "/look-here-instead"

      stub_publishing_api_unpublish(document.content_id, body: {
        type: "gone",
        explanation: explanatory_note,
        alternative_path: alternative_path,
        locale: document.locale,
      })
      UnpublishService.new.remove(document, explanatory_note: explanatory_note, alternative_path: alternative_path)

      expect(document.timeline_entries.first.entry_type).to eq("removed")
      expect(document.timeline_entries.first.removal.explanatory_note).to eq(explanatory_note)
      expect(document.timeline_entries.first.removal.alternative_path).to eq(alternative_path)
      expect(document.timeline_entries.first.removal.redirect).to be_falsey
    end

    it "keeps track of the live state" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", locale: document.locale })
      UnpublishService.new.remove(document)
      document.reload

      expect(document.live_state).to eq("removed")
    end
  end

  describe "#remove_and_redirect" do
    let(:document) { create(:document) }
    let(:redirect_path) { "/redirect-path" }

    it "removes documents with a redirect" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, locale: document.locale })
      UnpublishService.new.remove_and_redirect(document, redirect_path)

      assert_publishing_api_unpublish(document.content_id, type: "redirect", alternative_path: redirect_path, locale: document.locale)
    end

    it "deletes assets associated with redirected documents" do
      asset = create(:image, :in_preview, document: document)

      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, locale: document.locale })
      asset_manager_request = asset_manager_delete_asset(asset.asset_manager_id)

      UnpublishService.new.remove_and_redirect(document, redirect_path)

      assert_requested(asset_manager_request)
    end

    it "accepts an optional explanatory note" do
      explanatory_note = "The reason document has been removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, explanation: explanatory_note, locale: document.locale })

      UnpublishService.new.remove_and_redirect(document, redirect_path, explanatory_note: explanatory_note)

      assert_publishing_api_unpublish(document.content_id, type: "redirect", alternative_path: redirect_path, explanation: explanatory_note, locale: document.locale)
    end

    it "sets the locale of the document if specified" do
      french_document = create(:document, locale: "fr")

      stub_publishing_api_unpublish(french_document.content_id, body: { type: "redirect", alternative_path: redirect_path, locale: french_document.locale })
      UnpublishService.new.remove_and_redirect(french_document, redirect_path)

      assert_publishing_api_unpublish(french_document.content_id, type: "redirect", alternative_path: redirect_path, locale: french_document.locale)
    end

    it "adds an entry in the timeline of the document" do
      explanatory_note = "The reason document has been removed"

      stub_publishing_api_unpublish(document.content_id, body: {
        type: "redirect",
        explanation: explanatory_note,
        alternative_path: redirect_path,
        locale: document.locale,
      })

      UnpublishService.new.remove_and_redirect(document, redirect_path, explanatory_note: explanatory_note)

      expect(document.timeline_entries.first.entry_type).to eq("removed")
      expect(document.timeline_entries.first.removal.explanatory_note).to eq(explanatory_note)
      expect(document.timeline_entries.first.removal.alternative_path).to eq(redirect_path)
      expect(document.timeline_entries.first.removal.redirect).to be_truthy
    end

    it "keeps track of the live state" do
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, locale: document.locale })
      UnpublishService.new.remove_and_redirect(document, redirect_path)
      document.reload

      expect(document.live_state).to eq("removed")
    end
  end
end
