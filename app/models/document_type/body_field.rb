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

  def updater_params(_edition, params)
    body = params.dig(:revision, :contents, :body)
    { contents: { body: body } }
  end

  def pre_preview_issues(edition, revision)
    issues = Requirements::CheckerIssues.new

    unless GovspeakDocument.new(revision.contents[id], edition).valid?
      issues.create(id, :invalid_govspeak)
    end

    issues
  end

  alias_method :pre_update_issues, :pre_preview_issues

  def pre_publish_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new
    issues.create(id, :blank) if revision.contents[id].blank?
    issues
  end
end
