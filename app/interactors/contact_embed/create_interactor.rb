# frozen_string_literal: true

class ContactEmbed::CreateInteractor < ApplicationInteractor
  delegate :params,
           :markdown_code,
           :issues,
           to: :context

  def call
    check_for_issues
    generate_markdown_code
  end

private

  def check_for_issues
    return if params[:contact_id].present?

    issues = Requirements::CheckerIssues.new([
      Requirements::Issue.new(:contact_embed, :blank),
    ])

    context.fail!(issues: issues)
  end

  def generate_markdown_code
    context.markdown_code = I18n.t!("contact_embed.new.contact_markdown",
                                    id: params[:contact_id])
  end
end
