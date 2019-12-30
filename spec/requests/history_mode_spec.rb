# frozen_string_literal: true

RSpec.describe "History Mode" do
  describe "GET /documents/:document/history-mode" do
    it "returns a forbidden status for user without managing editor permission" do
      @edition = create(:edition)
      login_as(create(:user))
      get history_mode_path(@edition.document)
      expect(response.status).to eq(403)
      expect(response.body).to include(I18n.t!("history_mode.non_managing_editor.title", title: @edition.title))
    end

    it "does not return a forbidden status for user with managing editor permission" do
      @edition = create(:edition)
      login_as(create(:user, managing_editor: true))
      get history_mode_path(@edition.document)
      expect(response.status).to_not eq(403)
    end
  end

  describe "PATCH /documents/:document/history-mode" do
    it "returns a forbidden status for user without managing editor permission" do
      @edition = create(:edition)
      login_as(create(:user))
      patch history_mode_path(@edition.document)
      expect(response.status).to eq(403)
      expect(response.body).to include(I18n.t!("history_mode.non_managing_editor.title", title: @edition.title))
    end

    it "does not return a forbidden status for user with managing editor permission" do
      @edition = create(:edition)
      login_as(create(:user, managing_editor: true))
      patch history_mode_path(@edition.document)
      expect(response.status).to_not eq(403)
    end
  end
end
