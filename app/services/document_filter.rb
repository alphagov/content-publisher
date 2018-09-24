# frozen_string_literal: true

class DocumentFilter
  TAG_CONTAINS_QUERY = "exists(select 1 from json_array_elements(tags->'%<tag>s')
                        where array_to_json(array[value])->>0 = :value)"

  include ActiveRecord::Sanitization::ClassMethods

  SORT_KEYS = %w[updated_at].freeze
  DEFAULT_SORT = "-updated_at"

  attr_reader :filters, :sort, :page, :per_page

  def initialize(params)
    @filters = params[:filters].to_h.symbolize_keys
    @sort = allowed_sort?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    @page = params[:page]
    @per_page = params[:per_page]
  end

  def documents
    scope = filtered_scope(Document)
    scope = ordered_scope(scope)
    scope.page(page).per(per_page)
  end

  def filter_params
    filters.select { |_, value| value.present? }.tap do |params|
      params[:sort] = sort if sort != DEFAULT_SORT
      params[:page] = page if page != "1"
    end
  end

private

  def allowed_sort?(sort)
    SORT_KEYS.flat_map { |item| [item, "-#{item}"] }.include?(sort)
  end

  def filtered_scope(scope)
    filters.inject(scope) do |memo, (field, value)|
      next memo if value.blank?

      case field
      when :title_or_url
        memo.where("title ILIKE ? OR base_path ILIKE ?",
                   "%#{sanitize_sql_like(value)}%",
                   "%#{sanitize_sql_like(value)}%")
      when :document_type
        memo.where(document_type: value)
      when :state
        UserFacingState.scope(memo, value)
      when :organisation
        memo.where(TAG_CONTAINS_QUERY % { tag: "organisations" } + " OR " +
                   TAG_CONTAINS_QUERY % { tag: "primary_publishing_organisation" },
                   value: value)
      else
        memo
      end
    end
  end

  def ordered_scope(scope)
    direction = sort.chars.first == "-" ? :desc : :asc
    scope.order(sort.delete_prefix("-") => direction)
  end
end
