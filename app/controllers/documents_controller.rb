# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    if filter_params[:filters].empty? && current_user.organisation_content_id
      redirect_to documents_path(organisation: current_user.organisation_content_id)
      return
    end

    filter = EditionFilter.new(current_user, filter_params)
    @editions = filter.editions
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def show
    @edition = Edition.find_current(document: params[:document])
  end

  def history
    @edition = Edition.find_current(document: params[:document])
    @timeline_entries = TimelineEntry.where(document: @edition.document)
                                     .includes(:created_by, :details)
                                     .order(created_at: :desc)
                                     .includes(:edition)
                                     .page(params.fetch(:page, 1))
                                     .per(50)
  end

  def generate_path
    edition = Edition.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
    base_path = GenerateBasePathService.call(edition.document, params[:title])
    render plain: base_path
  end

private

  def filter_params
    filters = params.slice(:title_or_url,
                           :document_type,
                           :status,
                           :organisation,
                           :gets_history_mode,
                           :in_history_mode).permit!
    {
      filters: filters,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    }
  end
end
