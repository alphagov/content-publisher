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
    { contents: { body: params[:body] } }
  end

  def pre_update_issues(edition, params)
    issues = Requirements::CheckerIssues.new

    unless GovspeakDocument.new(params[:contents][:body], edition).valid?
      issues.create(id, :invalid_govspeak)
    end

    issues
  end

  def pre_preview_issues(edition)
    pre_update_issues(edition, contents: edition.contents.symbolize_keys)
  end

  def pre_publish_issues(_edition, revision)
    issues = Requirements::CheckerIssues.new
    issues.create(id, :blank) if revision.contents[id].blank?
    issues
  end
end
