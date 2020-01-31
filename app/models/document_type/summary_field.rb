# frozen_string_literal: true

class DocumentType::SummaryField
  SUMMARY_MAX_LENGTH = 600

  def id
    "summary"
  end

  def payload(edition)
    { description: edition.summary }
  end

  def updater_params(_edition, params)
    { summary: params[:summary]&.strip }
  end

  def pre_preview_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new

    if revision.summary.to_s.size > SUMMARY_MAX_LENGTH
      issues << Requirements::Issue.new(:summary, :too_long, max_length: SUMMARY_MAX_LENGTH)
    end

    if revision.summary.to_s.lines.count > 1
      issues << Requirements::Issue.new(:summary, :multiline)
    end

    issues
  end

  alias_method :pre_update_issues, :pre_preview_issues

  def pre_publish_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new

    if revision.summary.blank?
      issues << Requirements::Issue.new(:summary, :blank)
    end

    issues
  end
end
