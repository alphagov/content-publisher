# frozen_string_literal: true

class DocumentsController < ApplicationController
  include GDS::SSO::ControllerMethods

  def index
    filter = DocumentFilter.new(filter_params)
    @documents = filter.documents
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def show
    @document = Document.find_by_param(params[:id])
  end

  def confirm_delete_draft
    document = Document.find_by_param(params[:id])
    redirect_to document_path(document), confirmation: "documents/show/delete_draft"
  end

  def destroy
    document = Document.find_by_param(params[:id])
    DeleteDraftService.new(document).delete
    redirect_to documents_path
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document, alert_with_description: t("documents.show.flashes.delete_draft_error")
  end

  def update
    @document = Document.find_by_param(params[:id])
    @document.assign_attributes(update_params(@document))
    add_contact_request = params[:submit] == "add_contact"
    @issues = Requirements::EditPageChecker.new(@document).pre_preview_issues

    if @issues.any?
      flash.now["alert"] = {
        "title" => I18n.t!("documents.edit.flashes.requirements"),
        "items" => @issues.items,
      }

      render :edit
      return
    end

    PreviewService.new(@document).try_create_preview(
      user: current_user,
      type: "updated_content",
    )

    if add_contact_request
      redirect_to search_document_contacts_path(@document)
    else
      redirect_to @document
    end
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to @document, alert_with_description: t("documents.show.flashes.preview_error")
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  end

  def debug
    authorise_user!(User::DEBUG_PERMISSION)
    @document = Document.find_by_param(params[:id])
    @papertrail_users = User.where(id: @document.versions.pluck(:whodunnit))
  end

private

  def filter_params
    {
      filters: params.permit(:title_or_url, :document_type, :state, :organisation).to_hash,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    }
  end

  def update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    base_path = PathGeneratorService.new.path(document, params[:document][:title])

    params.require(:document).permit(:title, :summary, :update_type, :change_note, contents: contents_params)
      .merge(base_path: base_path)
  end
end
