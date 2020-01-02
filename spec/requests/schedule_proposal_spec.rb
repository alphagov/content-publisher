# frozen_string_literal: true

RSpec.describe "Schedule Proposal" do
  it_behaves_like "requests that assert edition state",
                  "schedule proposing on a non editable edition",
                  routes: { schedule_proposal_path: %i[get post delete] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/schedule-proposal" do
    let(:edition) { create(:edition) }

    it "returns successfully" do
      get schedule_proposal_path(edition.document)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /documents/:document/schedule-proposal" do
    let(:edition) { create(:edition) }
    let(:schedule_params) do
      tomorrow = Time.zone.tomorrow
      {
        time: "9:00am",
        date: { day: tomorrow.day, month: tomorrow.month, year: tomorrow.year },
      }
    end

    it "redirects to the document path" do
      post schedule_proposal_path(edition.document),
           params: { schedule: schedule_params }

      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      post schedule_proposal_path(edition.document),
           params: { schedule: { time: "9:00am", date: { day: "" } } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.schedule_date.invalid.form_message"),
      )
    end

    context "when requested in the schedule wizard" do
      it "redirects to schedule when the schedule action is selected" do
        post schedule_proposal_path(edition.document, wizard: "schedule"),
             params: { schedule: schedule_params.merge(action: "schedule") }

        expect(response).to redirect_to(
          new_schedule_path(edition.document, wizard: "schedule"),
        )
      end

      it "redirects to document summary when the save action is selected" do
        post schedule_proposal_path(edition.document, wizard: "schedule"),
             params: { schedule: schedule_params.merge(action: "save") }

        expect(response).to redirect_to(document_path(edition.document))
      end

      it "returns an issue and unprocessable response when no action is selected" do
        post schedule_proposal_path(edition.document, wizard: "schedule"),
             params: { schedule: schedule_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to have_content(
          I18n.t!("requirements.schedule_action.not_selected.form_message"),
        )
      end
    end
  end

  describe "DELETE /documents/:document/schedule-proposal" do
    it "redirects to document summary" do
      edition = create(:edition)
      delete schedule_proposal_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
    end
  end
end
