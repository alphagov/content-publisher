# frozen_string_literal: true

require "rake"

RSpec.feature "Unpublish documents rake tasks" do
  describe "unpublish:retire_document" do
    before do
      Rake::Task["unpublish:retire_document"].reenable
    end

    it "runs the task to retire a document" do
      document = create(:document, base_path: "/a-base-path")
      explanatory_note = "The reason the document is being retired"

      stub_publishing_api_unpublish(document.content_id, body: { type: "withdrawal", explanation: explanatory_note })
      expect_any_instance_of(DocumentUnpublishingService).to receive(:retire).with(document, explanatory_note)

      ENV["BASE_PATH"] = "/a-base-path"
      ENV["NOTE"] = explanatory_note
      Rake::Task["unpublish:retire_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["BASE_PATH"] = nil
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing BASE_PATH value")
    end

    it "raises an error if a NOTE is not present" do
      ENV["BASE_PATH"] = "/a-base-path"
      ENV["NOTE"] = nil
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing NOTE value")
    end
  end

  describe "unpublish:remove_document" do
    before do
      Rake::Task["unpublish:remove_document"].reenable
    end

    it "runs the rake task to remove a document" do
      document = create(:document, base_path: "/a-base-path")
      stub_publishing_api_unpublish(document.content_id, body: { type: "gone" })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove).with(document)

      ENV["BASE_PATH"] = "/a-base-path"
      Rake::Task["unpublish:remove_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["BASE_PATH"] = nil
      expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Missing BASE_PATH value")
    end
  end

  describe "unpublish:remove_and_redirect_document" do
    before do
      Rake::Task["unpublish:remove_and_redirect_document"].reenable
    end

    it "runs the rake task to remove a document with a redirect" do
      document = create(:document, base_path: "/a-base-path")
      redirect_path = "/redirect-path"
      stub_publishing_api_unpublish(document.content_id, body: { type: "redirect", alternative_path: redirect_path })

      expect_any_instance_of(DocumentUnpublishingService).to receive(:remove_and_redirect).with(document, redirect_path)

      ENV["BASE_PATH"] = "/a-base-path"
      ENV["REDIRECT"] = redirect_path
      Rake::Task["unpublish:remove_and_redirect_document"].invoke
    end

    it "raises an error if a BASE_PATH is not present" do
      ENV["BASE_PATH"] = nil
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing BASE_PATH value")
    end

    it "raises an error if a REDIRECT is not present" do
      ENV["BASE_PATH"] = "/a-base-path"
      ENV["REDIRECT"] = nil
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke("/a-base-path") }.to raise_error("Missing REDIRECT value")
    end
  end
end
