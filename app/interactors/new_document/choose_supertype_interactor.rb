# frozen_string_literal: true

class NewDocument::ChooseSupertypeInteractor < ApplicationInteractor
  delegate :user,
           :params,
           :supertype,
           to: :context

  def call
    check_for_issues
    find_supertype
  end

private

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:supertype, :not_selected) if params[:supertype].blank?
    context.fail!(issues: issues) if issues.any?
  end

  def find_supertype
    context.supertype = Supertype.find(params[:supertype])
  end
end
