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

      expect_any_instance_of(UnpublishService).to receive(:retire).with(document, explanatory_note)

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

  describe "unpublish:remove_document" do
    before do
      Rake::Task["unpublish:remove_document"].reenable
    end

    it "runs the rake task to remove a document" do
      document = create(:document, :published, locale: "en")

      expect_any_instance_of(UnpublishService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: nil,
      )

      Rake::Task["unpublish:remove_document"].invoke(document.content_id)
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove_document"].invoke }.to raise_error("Missing content_id parameter")
    end

    it "sets an optional explanatory note" do
      document = create(:document, :published, locale: "en")
      explanatory_note = "The reason the document is being removed"

      expect_any_instance_of(UnpublishService).to receive(:remove).with(
        document,
        explanatory_note: explanatory_note,
        alternative_path: nil,
      )

      ClimateControl.modify NOTE: explanatory_note do
        Rake::Task["unpublish:remove_document"].invoke(document.content_id)
      end
    end

    it "sets an optional alternative path" do
      document = create(:document, :published, locale: "en")
      alternative_path = "/go-here-instead"

      expect_any_instance_of(UnpublishService).to receive(:remove).with(
        document,
        explanatory_note: nil,
        alternative_path: alternative_path,
      )

      ClimateControl.modify NEW_PATH: alternative_path do
        Rake::Task["unpublish:remove_document"].invoke(document.content_id)
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")
      expect { Rake::Task["unpublish:remove_document"].invoke(document.content_id) }.to raise_error("Document must have a published version before it can be removed")
    end
  end

  describe "unpublish:remove_and_redirect_document" do
    before do
      Rake::Task["unpublish:remove_and_redirect_document"].reenable
    end

    it "runs the rake task to remove a document with a redirect" do
      document = create(:document, :published, locale: "en")
      redirect_path = "/redirect-path"

      expect_any_instance_of(UnpublishService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: nil,
      )

      ClimateControl.modify NEW_PATH: redirect_path do
        Rake::Task["unpublish:remove_and_redirect_document"].invoke(document.content_id)
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke }.to raise_error("Missing content_id parameter")
    end

    it "raises an error if a NEW_PATH is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke("a-content-id") }.to raise_error("Missing NEW_PATH value")
    end

    it "sets an optional explanatory note" do
      document = create(:document, :published, locale: "en")
      redirect_path = "/redirect-path"
      explanatory_note = "The reason the document is being removed"

      expect_any_instance_of(UnpublishService).to receive(:remove_and_redirect).with(
        document,
        redirect_path,
        explanatory_note: explanatory_note,
      )

      ClimateControl.modify NEW_PATH: redirect_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_and_redirect_document"].invoke(document.content_id)
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      document = create(:document, locale: "en")
      redirect_path = "/redirect-path"

      ClimateControl.modify NEW_PATH: redirect_path do
        expect { Rake::Task["unpublish:remove_and_redirect_document"].invoke(document.content_id) }.to raise_error("Document must have a published version before it can be redirected")
      end
    end
  end
end
