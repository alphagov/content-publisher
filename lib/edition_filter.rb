# frozen_string_literal: true

class EditionFilter
  include ActiveRecord::Sanitization::ClassMethods

  SORT_KEYS = %w[last_updated].freeze
  DEFAULT_SORT = "-last_updated"

  attr_reader :filters, :sort, :page, :per_page, :user

  def initialize(user, **params)
    @filters = params[:filters].to_h.symbolize_keys
    @sort = allowed_sort?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    @page = params.fetch(:page, 1).to_i
    @per_page = params[:per_page]
    @user = user
  end

  def editions
    revision_joins = { revision: %i[content_revision tags_revision metadata_revision] }
    scope = Edition.where(current: true)
                   .left_joins(:access_limit)
                   .joins(revision_joins, :status, :document)
                   .preload(revision_joins, :status, :document, :last_edited_by)
    scope = access_limited_scope(scope)
    scope = filtered_scope(scope)
    scope = ordered_scope(scope)
    scope.page(page).per(per_page)
  end

  def filter_params
    filters.dup.tap do |params|
      params[:sort] = sort if sort != DEFAULT_SORT
      params[:page] = page if page > 1
    end
  end

private

  def allowed_sort?(sort)
    SORT_KEYS.flat_map { |item| [item, "-#{item}"] }.include?(sort)
  end

  def access_limited_scope(scope)
    return scope if user.has_permission?(User::ACCESS_LIMIT_OVERRIDE_PERMISSION)

    organisation_id = user.organisation_content_id
    no_access_limit = scope.where(access_limit: nil)
    primary_org_access = scope.merge(AccessLimit.primary_organisation)
                              .merge(TagsRevision.primary_organisation_is(organisation_id))
    tagged_orgs_access = scope.merge(AccessLimit.tagged_organisations)
                              .merge(TagsRevision.tagged_organisations_include(organisation_id))

    no_access_limit.or(primary_org_access).or(tagged_orgs_access)
  end

  def filtered_scope(scope)
    filters.inject(scope) do |memo, (field, value)|
      next memo if value.blank?

      case field
      when :title_or_url
        memo.where("content_revisions.title ILIKE ? OR content_revisions.base_path ILIKE ?",
                   "%#{sanitize_sql_like(value)}%",
                   "%#{sanitize_sql_like(value)}%")
      when :document_type
        memo.where("metadata_revisions.document_type_id": value)
      when :status
        if value == "published"
          memo.where("statuses.state": %w[published published_but_needs_2i])
        else
          memo.where("statuses.state": value)
        end
      when :organisation
        memo.merge(TagsRevision.tagged_organisations_include(value))
      else
        memo
      end
    end
  end

  def ordered_scope(scope)
    direction = sort.chars.first == "-" ? :desc : :asc
    case sort.delete_prefix("-")
    when "last_updated"
      scope.order("editions.last_edited_at #{direction}")
    else
      scope
    end
  end
end
