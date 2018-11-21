# frozen_string_literal: true

require "rake"

RSpec.feature "Unpublish documents rake tasks" do
  describe "unpublish:retire_document" do
    before do
      Rake::Task["unpublish:retire_document"].reenable
    end

    it "runs the task to retire a document" do
      document = create(:document, locale: "en")
      explanatory_note = "The reason the document is being retired"

      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note })
      expect_any_instance_of(DocumentUnpublishingService).to receive(:retire).with(document, explanatory_note, locale: "en")

      ENV["CONTENT_ID"] = document.content_id
      ENV["NOTE"] = explanatory_note
      Rake::Task["unpublish:retire_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["CONTENT_ID"] = nil
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "raises an error if a NOTE is not present" do
      ENV["CONTENT_ID"] = "a-content-id"
      ENV["NOTE"] = nil
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing NOTE value")
    end
  end

  describe "unpublish:remove_document" do
    before do
      Rake::Task["unpublish:remove_document"].reenable
    end

    it "runs the rake task to remove a document" do
      document = create(:document, locale: "en")
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: nil,
        locale: "en",
      )

      ENV["CONTENT_ID"] = document.content_id
      Rake::Task["unpublish:remove_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["CONTENT_ID"] = nil
      expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "sets an optional explanatory note" do
      document = create(:document, locale: "en")
      explanatory_note = "The reason the document is being removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone", explanation: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: explanatory_note,
        alternative_path: nil,
        locale: "en",
      )

      ENV["CONTENT_ID"] = document.content_id
      ENV["NOTE"] = explanatory_note
      ENV["NEW_PATH"] = nil
      Rake::Task["unpublish:remove_document"].invoke
    end

    it "sets an optional alternative path" do
      document = create(:document, locale: "en")
      alternative_path = "/go-here-instead"
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: alternative_path,
        locale: "en",
      )

      ENV["CONTENT_ID"] = document.content_id
      ENV["NOTE"] = nil
      ENV["NEW_PATH"] = alternative_path
      Rake::Task["unpublish:remove_document"].invoke
    end
  end

  describe "unpublish:remove_and_redirect_document" do
    before do
      Rake::Task["unpublish:remove_and_redirect_document"].reenable
    end

    it "runs the rake task to remove a document with a redirect" do
      document = create(:document, locale: "en")
      redirect_path = "/redirect-path"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: nil,
        locale: "en",
      )

      ENV["CONTENT_ID"] = document.content_id
      ENV["NEW_PATH"] = redirect_path
      Rake::Task["unpublish:remove_and_redirect_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["CONTENT_ID"] = nil
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing CONTENT_ID value")
    end

    it "raises an error if a NEW_PATH is not present" do
      ENV["CONTENT_ID"] = "a-content-id"
      ENV["NEW_PATH"] = nil
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing NEW_PATH value")
    end

    it "sets an optional explanatory note" do
      document = create(:document, locale: "en")
      redirect_path = "/redirect-path"
      explanatory_note = "The reason the document is being removed"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path, explanatory_note: explanatory_note })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: explanatory_note,
        locale: "en",
      )

      ENV["CONTENT_ID"] = document.content_id
      ENV["NEW_PATH"] = redirect_path
      ENV["NOTE"] = explanatory_note
      Rake::Task["unpublish:remove_and_redirect_document"].invoke
    end
  end
end
