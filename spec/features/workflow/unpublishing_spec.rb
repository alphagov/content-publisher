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

      Rake::Task["unpublish:retire_document"].invoke("/a-base-path", explanatory_note)
    end

    it "raises an error if a base_path is not present" do
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing base_path parameter")
    end

    it "raises an error if an explanatory_note is not present" do
      expect { Rake::Task["unpublish:retire_document"].invoke("/a-base-path") }.to raise_error("Missing explanatory_note parameter")
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

      Rake::Task["unpublish:remove_document"].invoke("/a-base-path")
    end

    it "raises an error if a base_path is not present" do
      expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Missing base_path parameter")
    end
  end
end
