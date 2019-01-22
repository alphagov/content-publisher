# frozen_string_literal: true

RSpec.describe "Unpublish rake tasks" do
  let(:edition) { create(:edition, :published, locale: "en") }

  describe "unpublish:withdraw" do
    before do
      Rake::Task["unpublish:withdraw"].reenable
    end

    it "runs the task to withdraw an edition" do
      public_explanation = "The reason the document is being withdrawn"

      expect_any_instance_of(UnpublishService)
        .to receive(:withdraw).with(edition, public_explanation)

      ClimateControl.modify NOTE: public_explanation do
        Rake::Task["unpublish:withdraw"].invoke(edition.content_id)
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:withdraw"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "raises an error if a NOTE is not present" do
      expect { Rake::Task["unpublish:withdraw"].invoke("a-content-id") }
        .to raise_error("Missing NOTE value")
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      draft = create(:edition, locale: "en")
      public_explanation = "The reason the document is being withdrawn"

      ClimateControl.modify NOTE: public_explanation do
        expect { Rake::Task["unpublish:withdraw"].invoke(draft.content_id) }
          .to raise_error("Document must have a published version before it can be withdrawn")
      end
    end
  end

  describe "unpublish:remove" do
    before do
      Rake::Task["unpublish:remove"].reenable
    end

    it "runs the rake task to remove a document" do
      expect_any_instance_of(UnpublishService)
        .to receive(:remove).with(edition,
                                  explanatory_note: nil,
                                  alternative_path: nil)

      Rake::Task["unpublish:remove"].invoke(edition.content_id)
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "sets an optional explanatory note" do
      explanatory_note = "The reason the document is being removed"

      expect_any_instance_of(UnpublishService)
        .to receive(:remove).with(edition,
                                  explanatory_note: explanatory_note,
                                  alternative_path: nil)

      ClimateControl.modify NOTE: explanatory_note do
        Rake::Task["unpublish:remove"].invoke(edition.content_id)
      end
    end

    it "sets an optional alternative path" do
      alternative_path = "/go-here-instead"

      expect_any_instance_of(UnpublishService)
        .to receive(:remove).with(edition,
                                  explanatory_note: nil,
                                  alternative_path: alternative_path)

      ClimateControl.modify NEW_PATH: alternative_path do
        Rake::Task["unpublish:remove"].invoke(edition.content_id)
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      draft = create(:edition, locale: "en")

      expect { Rake::Task["unpublish:remove"].invoke(draft.content_id) }
        .to raise_error("Document must have a published version before it can be removed")
    end
  end

  describe "unpublish:remove_and_redirect" do
    before do
      Rake::Task["unpublish:remove_and_redirect"].reenable
    end

    it "runs the rake task to remove a document with a redirect" do
      redirect_path = "/redirect-path"

      expect_any_instance_of(UnpublishService)
        .to receive(:remove_and_redirect).with(edition,
                                               redirect_path,
                                               explanatory_note: nil)

      ClimateControl.modify NEW_PATH: redirect_path do
        Rake::Task["unpublish:remove_and_redirect"].invoke(edition.content_id)
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "raises an error if a NEW_PATH is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect"].invoke("a-content-id") }
        .to raise_error("Missing NEW_PATH value")
    end

    it "sets an optional explanatory note" do
      redirect_path = "/redirect-path"
      explanatory_note = "The reason the document is being removed"

      expect_any_instance_of(UnpublishService)
        .to receive(:remove_and_redirect).with(edition,
                                               redirect_path,
                                               explanatory_note: explanatory_note)

      ClimateControl.modify NEW_PATH: redirect_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_and_redirect"].invoke(edition.content_id)
      end
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      draft = create(:edition, locale: "en")

      ClimateControl.modify NEW_PATH: "/redirect" do
        expect { Rake::Task["unpublish:remove_and_redirect"].invoke(draft.content_id) }
          .to raise_error("Document must have a published version before it can be redirected")
      end
    end
  end
end
