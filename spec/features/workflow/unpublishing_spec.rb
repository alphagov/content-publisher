# frozen_string_literal: true

require "rake"

RSpec.feature "Unpublish documents rake tasks" do
  describe "unpublish:retire_document" do
    before do
      Rake::Task["unpublish:retire_document"].reenable
    end

    it "runs the task to retire a document" do
      document = create(:document, :published, locale: "en")
      explanatory_note = "The reason the document is being retired"

      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note })
      expect_any_instance_of(DocumentUnpublishingService).to receive(:retire).with(document, explanatory_note, locale: "en")


      ClimateControl.modify CONTENT_ID: document.content_id, NOTE: explanatory_note do
        Rake::Task["unpublish:retire_document"].invoke
      end
    end

    it "raises an error if a BASE_PATH is not present" do
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "raises an error if a NOTE is not present" do
      ClimateControl.modify CONTENT_ID: "a-content-id" do
        expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing NOTE value")
      end
    end

    it "copes with commas in the explanatory note" do
      document = create(:document, :published, locale: "en")
      explanatory_note = "The reason the document is being retired, firstly, secondly and so forth"

      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note })
      expect_any_instance_of(DocumentUnpublishingService).to receive(:retire).with(document, explanatory_note, locale: "en")

      ClimateControl.modify CONTENT_ID: document.content_id, NOTE: explanatory_note do
        Rake::Task["unpublish:retire_document"].invoke
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")
      explanatory_note = "The reason the document is being retired"

      ClimateControl.modify CONTENT_ID: document.content_id, NOTE: explanatory_note do
        expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Document must have a published version before it can be retired")
      end
    end
  end

  describe "unpublish:remove_document" do
    before do
      Rake::Task["unpublish:remove_document"].reenable
    end

    it "runs the rake task to remove a document" do
      document = create(:document, :published, locale: "en")
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: nil,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id do
        Rake::Task["unpublish:remove_document"].invoke
      end
    end

    it "raises an error if a BASE_PATH is not present" do
      expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "sets an optional explanatory note" do
      document = create(:document, :published, locale: "en")
      explanatory_note = "The reason the document is being removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", explanation: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: explanatory_note,
        alternative_path: nil,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_document"].invoke
      end
    end

    it "copes with commas in the explanatory note" do
      document = create(:document, :published, locale: "en")
      explanatory_note = "The reason the document is being removed, firstly, secondly and so forth"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", explanation: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: explanatory_note,
        alternative_path: nil,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_document"].invoke
      end
    end

    it "sets an optional alternative path" do
      document = create(:document, :published, locale: "en")
      alternative_path = "/go-here-instead"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: alternative_path,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NEW_PATH: alternative_path do
        Rake::Task["unpublish:remove_document"].invoke
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")

      ClimateControl.modify CONTENT_ID: document.content_id do
        expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Document must have a published version before it can be removed")
      end
    end
  end

  describe "unpublish:remove_and_redirect_document" do
    before do
      Rake::Task["unpublish:remove_and_redirect_document"].reenable
    end

    it "runs the rake task to remove a document with a redirect" do
      document = create(:document, :published, locale: "en")
      redirect_path = "/redirect-path"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: nil,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NEW_PATH: redirect_path do
        Rake::Task["unpublish:remove_and_redirect_document"].invoke
      end
    end

    it "raises an error if a BASE_PATH is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "raises an error if a NEW_PATH is not present" do
      ClimateControl.modify CONTENT_ID: "a-content-id" do
        expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing NEW_PATH value")
      end
    end

    it "sets an optional explanatory note" do
      document = create(:document, :published, locale: "en")
      redirect_path = "/redirect-path"
      explanatory_note = "The reason the document is being removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, explanatory_note: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: explanatory_note,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NEW_PATH: redirect_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_and_redirect_document"].invoke
      end
    end

    it "copes with commas in the explanatory note" do
      document = create(:document, :published, locale: "en")
      redirect_path = "/redirect-path"
      explanatory_note = "The reason the document is being removed, firstly, secondly and so forth"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, explanatory_note: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: explanatory_note,
        locale: "en",
      )

      ClimateControl.modify CONTENT_ID: document.content_id, NEW_PATH: redirect_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_and_redirect_document"].invoke
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")
      redirect_path = "/redirect-path"

      ClimateControl.modify CONTENT_ID: document.content_id, NEW_PATH: redirect_path do
        expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Document must have a published version before it can be redirected")
      end
    end
  end
end
