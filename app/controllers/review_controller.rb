# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    document = Document.find_by_param(params[:id])
    document.update!(review_state: "submitted_for_review")
    redirect_to document, notice: "Content has been submitted for 2i review"
  end

  def approve
    document = Document.find_by_param(params[:id])
    document.update!(review_state: "reviewed")
    redirect_to document, notice: "Content has been reviewed and approved"
  end
end
