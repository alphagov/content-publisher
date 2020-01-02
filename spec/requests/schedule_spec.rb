# frozen_string_literal: true

RSpec.describe "Schedule" do
  it_behaves_like "requests that assert edition state",
                  "scheduling a non editable edition",
                  routes: { new_schedule_path: %i[get post] } do
    let(:edition) { create(:edition, :scheduled) }
  end

  it_behaves_like "requests that assert edition state",
                  "scheduling an edition without a proposed publish time",
                  routes: { new_schedule_path: %i[get post] } do
    let(:edition) { create(:edition, proposed_publish_time: nil) }
  end

  it_behaves_like "requests that assert edition state",
                  "managing the scheduling of a non-scheduled edition",
                  routes: { edit_schedule_path: %i[get patch],
                            schedule_path: %i[delete],
                            scheduled_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/schedule/new" do
    it "redirects to document summary with errors when the content isn't publishable" do
      edition = create(:edition, :schedulable, summary: "")
      get new_schedule_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      expect(flash[:tried_to_publish]).to be true
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("requirements.summary.blank.summary_message"))
    end

    it "redirects to document summary when the content isn't schedulable" do
      edition = create(:edition,
                       :publishable,
                       proposed_publish_time: Time.zone.yesterday)
      get new_schedule_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to include(
        I18n.t!("requirements.schedule_date.in_the_past.summary_message"),
      )
    end
  end

  describe "POST /documents/:document/schedule/new" do
    before { stub_any_publishing_api_put_intent }

    it "redirects to a success page when scheduling is successful" do
      edition = create(:edition, :schedulable)
      post new_schedule_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(scheduled_path(edition.document))
    end

    it "returns requirement issues with unprocessable status when input has issues" do
      edition = create(:edition, :schedulable)
      post new_schedule_path(edition.document), params: { review_status: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(
        I18n.t!("requirements.schedule_review_status.not_selected.form_message"),
      )
    end

    it "redirects to document summary with an alert when Publishing API is down" do
      stub_publishing_api_isnt_available

      edition = create(:edition, :schedulable)
      post new_schedule_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("documents.show.flashes.schedule_error.title"))
    end
  end

  describe "PATCH /documents/:document/schedule/edit" do
    before { stub_any_publishing_api_put_intent }

    let(:edition) { create(:edition, :scheduled) }
    let(:schedule_params) do
      tomorrow = Time.zone.tomorrow
      {
        time: "9:00am",
        date: { day: tomorrow.day, month: tomorrow.month, year: tomorrow.year },
      }
    end

    it "redirects to document summary on successful rescheduling" do
      patch edit_schedule_path(edition.document),
            params: { schedule: schedule_params }

      expect(response).to redirect_to(document_path(edition.document))
    end

    it "shows issues and returns unprocessable when there are requirement issues" do
      patch edit_schedule_path(edition.document),
            params: { schedule: { time: "9:00am", date: { day: "" } } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to include(I18n.t!("requirements.schedule_date.invalid.form_message"))
    end

    it "redirects to document summary with an error when Publishing API is down" do
      stub_publishing_api_isnt_available

      patch edit_schedule_path(edition.document),
            params: { schedule: schedule_params }
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("documents.show.flashes.schedule_error.title"))
    end
  end

  describe "DELETE /documents/:document/schedule" do
    let(:edition) { create(:edition, :scheduled) }

    it "redirects to document summary on success" do
      stub_publishing_api_destroy_intent(edition.base_path)
      delete schedule_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
    end

    it "redirects to document summary with an error when Publishing API is down" do
      stub_publishing_api_isnt_available
      delete schedule_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("documents.show.flashes.unschedule_error.title"))
    end
  end
end
