# frozen_string_literal: true

class DocumentType::TitleAndBasePathField
  TITLE_MAX_LENGTH = 300

  def id
    "title_and_base_path"
  end

  def payload(edition)
    {
      base_path: edition.base_path,
      title: edition.title,
      routes: [
        { path: edition.base_path, type: "exact" },
      ],
    }
  end

  def updater_params(edition, params)
    title = params[:title]&.strip
    base_path = GenerateBasePathService.call(edition, title: title)
    { title: title, base_path: base_path }
  end

  def pre_update_issues(edition, params)
    base_path_issues(edition, params) + title_issues(params[:title])
  end

  def pre_preview_issues(edition)
    title_issues(edition.title)
  end

  def pre_publish_issues(_edition, _revision)
    Requirements::CheckerIssues.new
  end

private

  def title_issues(title)
    issues = Requirements::CheckerIssues.new

    if title.blank?
      issues.create(:title, :blank)
    end

    if title.to_s.size > TITLE_MAX_LENGTH
      issues.create(:title, :too_long, max_length: TITLE_MAX_LENGTH)
    end

    if title.to_s.lines.count > 1
      issues.create(:title, :multiline)
    end

    issues
  end

  def base_path_issues(edition, params)
    issues = Requirements::CheckerIssues.new

    begin
      if base_path_conflict?(edition, params)
        issues.create(:title, :conflict)
      end
    rescue GdsApi::BaseError => e
      GovukError.notify(e)
    end

    issues
  end

  def base_path_conflict?(edition, params)
    base_path_owner = GdsApi.publishing_api.lookup_content_id(
      base_path: params[:base_path],
      with_drafts: true,
      exclude_document_types: [],
      exclude_unpublishing_types: [],
    )

    base_path_owner && base_path_owner != edition.content_id
  end
end
