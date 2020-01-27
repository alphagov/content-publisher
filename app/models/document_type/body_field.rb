# frozen_string_literal: true

class DocumentType::BodyField
  def id
    "body"
  end

  def payload(edition)
    {
      details: {
        body: GovspeakDocument.new(edition.contents[id], edition).payload_html,
      },
    }
  end

  def pre_preview_issues(edition, revision)
    issues = Requirements::CheckerIssues.new

    unless GovspeakDocument.new(revision.contents[id], edition).valid?
      issues << Requirements::Issue.new(id, :invalid_govspeak)
    end

    issues
  end

  alias_method :pre_update_issues, :pre_preview_issues

  def pre_publish_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new

    if revision.contents[id].blank?
      issues << Requirements::Issue.new(id, :blank)
    end

    issues
  end
end
