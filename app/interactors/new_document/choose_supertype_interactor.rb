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
    return if params[:supertype].present?

    context.fail!(issues: supertype_issues)
  end

  def find_supertype
    context.supertype = Supertype.find(params[:supertype])
  end

  def supertype_issues
    Requirements::CheckerIssues.new([
      Requirements::Issue.new(:supertype, :not_selected),
    ])
  end
end
