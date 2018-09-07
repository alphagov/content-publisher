# frozen_string_literal: true

class DocumentFilter
  SORT_KEYS = %w[updated_at].freeze
  DEFAULT_SORT = "-updated_at"

  attr_reader :filters, :sort, :page, :per_page

  def initialize(filters: {}, sort: nil, page: nil, per_page: nil)
    @filters = filters.symbolize_keys
    @sort = allowed_sort?(sort) ? sort : DEFAULT_SORT
    @page = page
    @per_page = per_page
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
        memo.where("title ILIKE ? OR base_path ILIKE ?", "%#{value}%", "%#{value}%")
      when :document_type
        memo.where(document_type: value)
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
