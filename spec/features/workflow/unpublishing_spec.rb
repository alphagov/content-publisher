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

      expect_any_instance_of(DocumentUnpublishingService).to receive(:retire).with(document, explanatory_note)

      ClimateControl.modify NOTE: explanatory_note do
        Rake::Task["unpublish:retire_document"].invoke(document.content_id)
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:retire_document"].invoke }.to raise_error("Missing content_id parameter")
    end

    it "raises an error if a NOTE is not present" do
      expect { Rake::Task["unpublish:retire_document"].invoke("a-content-id") }.to raise_error("Missing NOTE value")
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")
      explanatory_note = "The reason the document is being retired"

      ClimateControl.modify NOTE: explanatory_note do
        expect { Rake::Task["unpublish:retire_document"].invoke(document.content_id) }.to raise_error("Document must have a published version before it can be retired")
      end
    end
  end
end
