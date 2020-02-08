# frozen_string_literal: true

RSpec.describe "Remove tasks" do
  before do
    stub_any_publishing_api_unpublish
    allow(RemoveDocumentService).to receive(:call).and_call_original
  end

  let(:edition) { create(:edition, :published, locale: "en") }

  describe "remove:gone" do
    before { Rake::Task["remove:gone"].reenable }

    it "delegates to RemoveDocumentService" do
      note = "The reason the edition is being removed"

      ClimateControl.modify NOTE: note do
        Rake::Task["remove:gone"].invoke(edition.content_id)
      end

      expect(RemoveDocumentService).to have_received(:call) do |removed_edition, removal|
        expect(removed_edition).to eq(edition)
        expect(removal.explanatory_note).to eq(note)
      end
    end

    it "accepts a URL" do
      url = "https://example.com"

      ClimateControl.modify NOTE: "My note", URL: url do
        Rake::Task["remove:gone"].invoke(edition.content_id)
      end

      expect(RemoveDocumentService).to have_received(:call) do |_, removal|
        expect(removal.alternative_url).to eq(url)
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["remove:gone"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      draft = create(:edition, locale: "en")

      expect { Rake::Task["remove:gone"].invoke(draft.content_id) }
        .to raise_error("Document must have a published version before it can be removed")
    end
  end

  describe "remove:redirect" do
    before { Rake::Task["remove:redirect"].reenable }

    it "delegates to RemoveDocumentService" do
      note = "The reason the edition is being removed"
      url = "/redirect-url"

      ClimateControl.modify NOTE: note, URL: url do
        Rake::Task["remove:redirect"].invoke(edition.content_id)
      end

      expect(RemoveDocumentService).to have_received(:call) do |removed_edition, removal|
        expect(removed_edition).to eq(edition)
        expect(removal.attributes)
          .to match(
            a_hash_including(
              "explanatory_note" => note,
              "alternative_url" => url,
              "redirect" => true,
            ),
          )
      end
    end

    it "raises an error if a content_id is not present" do
      expect { Rake::Task["remove:redirect"].invoke }
        .to raise_error("Missing content_id parameter")
    end

    it "raises an error if a URL is not present" do
      expect { Rake::Task["remove:redirect"].invoke("a-content-id") }
        .to raise_error("Missing URL value")
    end

    it "raises an error if the document does not have a live version on GOV.uk" do
      draft = create(:edition, locale: "en")

      ClimateControl.modify URL: "/redirect" do
        expect { Rake::Task["remove:redirect"].invoke(draft.content_id) }
          .to raise_error("Document must have a published version before it can be redirected")
      end
    end
  end
end
