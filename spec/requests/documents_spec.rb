# frozen_string_literal: true

RSpec.describe "Documents" do
  describe "GET /documents/:document" do
    describe "history mode banner" do
      context "when in history mode" do
        it "shows the history mode banner" do
          edition = create(:edition, :political, :past_government)
          get document_path(edition.document)
          title = I18n.t!("documents.show.historical.title",
                          document_type: edition.document_type.label.downcase)
          description = I18n.t!("documents.show.historical.description",
                                government_name: edition.government.name)
          expect(response.body).to include(title)
          expect(response.body).to include(description)
        end

        it "won't show the history mode banner when the edition was created under the current government" do
          edition = create(:edition, :political, :current_government)
          get document_path(edition.document)
          title = I18n.t!("documents.show.historical.title",
                          document_type: edition.document_type.label.downcase)
          expect(response.body).not_to include(title)
        end
      end

      context "when not in history_mode" do
        it "won't show the history mode banner" do
          edition = create(:edition, :not_political)
          get document_path(edition.document)
          title = I18n.t!("documents.show.historical.title",
                          document_type: edition.document_type.label.downcase)
          expect(response.body).not_to include(title)
        end
      end
    end
  end
end
