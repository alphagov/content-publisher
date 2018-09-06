# frozen_string_literal: true

class DocumentsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def index
    filter = Filter.new(
      filters: params.permit(:title_or_url, :document_type).to_hash,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    )

    @documents = filter.documents
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @document = Document.find_by_param(params[:id]) end

  def show
    @document = Document.find_by_param(params[:id])
  end

  def update
    document = Document.find_by_param(params[:id])
    document.update!(update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "error_sending_to_draft")
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

  # TODO: Refactor to reduce duplication with #update
  def retry_draft_save
    document = Document.find_by_param(params[:id])
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "error_sending_to_draft")
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  rescue PathGeneratorService::ErrorGeneratingPath
    render status: :conflict
  end

private

  def index_params
    params.permit(:title_or_url, :document_type, :sort, :page)
  end

  def update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    base_path = PathGeneratorService.new.path(document, params[:document][:title])

    params.require(:document).permit(:title, :summary, :update_type, :change_note, contents: contents_params)
      .merge(base_path: base_path, publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")
  end

  class Filter
    SORT_KEYS = %w[updated_at].freeze
    DEFAULT_SORT = "-updated_at"

    attr_reader :filters, :sort, :page, :per_page

    def initialize(filters:, sort:, page: nil, per_page:)
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
        params.merge!(sort: sort) if sort != DEFAULT_SORT
        params.merge!(page: page) if page != "1"
      end
    end

  private

    def allowed_sort?(sort)
      SORT_KEYS.flat_map { |item| [item, "-#{item}"] }.include?(sort)
    end

    def filtered_scope(scope)
      filters.inject(scope) do |memo, (field, value)|
        next memo unless value.present?
        case field
        when :title_or_url
          memo.where("title ILIKE ? OR base_path ILIKE ?", "%#{value}%", "%#{value}%")
        when :document_type
          memo.where(document_type: value)
        end
      end
    end

    def ordered_scope(scope)
      direction = sort[0] == "-" ? :desc : :asc
      scope.order(sort.delete_prefix("-") => direction)
    end
  end
end
