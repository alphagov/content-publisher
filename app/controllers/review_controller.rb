# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    document = Document.find_by_param(params[:id])
    document.update!(review_state: "submitted_for_review")
    Event::DocumentSubmitted.create!(document: document, user: current_user)
    flash[:submitted_for_review] = true
    redirect_to document
  end

  def approve
    document = Document.find_by_param(params[:id])
    document.update!(review_state: "reviewed")
    Event::DocumentApproved.create!(document: document, user: current_user)
    redirect_to document, notice: t("documents.show.flashes.approved")
  end
end
