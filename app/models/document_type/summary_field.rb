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

  def pre_update_issues(_edition, params)
    issues = Requirements::CheckerIssues.new

    if params[:summary].to_s.size > SUMMARY_MAX_LENGTH
      issues.create(:summary, :too_long, max_length: SUMMARY_MAX_LENGTH)
    end

    if params[:summary].to_s.lines.count > 1
      issues.create(:summary, :multiline)
    end

    issues
  end

  def pre_preview_issues(edition)
    pre_update_issues(edition, summary: edition.summary)
  end

  def pre_publish_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new
    issues.create(:summary, :blank) if revision.summary.blank?
    issues
  end
end
