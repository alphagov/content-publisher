# frozen_string_literal: true

RSpec.describe "Unpublish rake tasks" do
  let(:edition) { create(:edition, :published, locale: "en") }

  describe "unpublish:remove" do
    before do
      Rake::Task["unpublish:remove"].reenable
    end

    it "removes the edition" do
      explanatory_note = "The reason the edition is being removed"
      alternative_path = "/path"

      unpublish_request = stub_publishing_api_unpublish(
        edition.content_id,
        body: {
          alternative_path: alternative_path,
          explanation: explanatory_note,
          locale: edition.locale,
          type: "gone",
        },
      )

      ClimateControl.modify NEW_PATH: alternative_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove"].invoke(edition.content_id)
      end

      expect(unpublish_request).to have_been_requested
      expect(edition.reload).to be_removed
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove"].invoke }
        .to raise_error("Missing content_id parameter")
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

    it "removes the edition with a redirect" do
      explanatory_note = "The reason the edition is being redirected"
      redirect_path = "/redirect-path"

      unpublish_request = stub_publishing_api_unpublish(
        edition.content_id,
        body: {
          alternative_path: redirect_path,
          explanation: explanatory_note,
          locale: edition.locale,
          type: "redirect",
        },
      )
      ClimateControl.modify NEW_PATH: redirect_path, NOTE: explanatory_note do
        Rake::Task["unpublish:remove_and_redirect"].invoke(edition.content_id)
      end

      expect(unpublish_request).to have_been_requested
      expect(edition.reload).to be_removed
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "raises an error if a NEW_PATH is not present" do
      expect { Rake::Task["unpublish:remove_and_redirect"].invoke("a-content-id") }
        .to raise_error("Missing NEW_PATH value")
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
