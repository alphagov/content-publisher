# frozen_string_literal: true

class ContactEmbed::CreateInteractor < ApplicationInteractor
  delegate :params,
           :markdown_code,
           :edition,
           :issues,
           to: :context

  def call
    find_edition
    check_for_issues
    generate_markdown_code
  end

private

  def find_edition
    context.edition = Edition.find_current(document: params[:document])
  end

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
