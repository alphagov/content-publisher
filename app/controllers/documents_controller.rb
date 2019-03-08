# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    filter = EditionFilter.new(filter_params)
    @editions = filter.editions
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @document = Document.with_current_edition.find_by_param(params[:id])
    @revision = @document.current_edition.revision
  end

  def show
    @document = Document.with_current_edition.find_by_param(params[:id])
    @edition = @document.current_edition
  end

  def confirm_delete_draft
    document = Document.with_current_edition.find_by_param(params[:id])
    redirect_to document_path(document), confirmation: "documents/show/delete_draft"
  end

  def destroy
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])

      begin
        current_edition = document.current_edition
        DeleteDraftService.new(document, current_user).delete

        TimelineEntry.create_for_status_change(entry_type: :draft_discarded,
                                               status: current_edition.status)

        redirect_to documents_path
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document, alert_with_description: t("documents.show.flashes.delete_draft_error")
      end
    end
  end

  def update
    Document.transaction do # rubocop:disable Metrics/BlockLength
      @document = Document.with_current_edition.lock.find_by_param(params[:id])
      current_edition = @document.current_edition
      current_revision = current_edition.revision

      @revision = current_revision.build_revision_update(update_params(@document),
                                                         current_user)

      add_contact_request = params[:submit] == "add_contact"
      @issues = Requirements::EditPageChecker.new(current_edition, @revision)
                                             .pre_preview_issues

      if @issues.any?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("documents.edit.flashes.requirements"),
          "items" => @issues.items,
        }

        render :edit, status: :unprocessable_entity
        return
      end

      if @revision != current_revision
        current_edition.assign_revision(@revision, current_user).save!

        TimelineEntry.create_for_revision(entry_type: :updated_content,
                                          edition: current_edition)

        PreviewService.new(current_edition).try_create_preview
      end

      if add_contact_request
        redirect_to search_contacts_path(@document)
      else
        redirect_to @document
      end
    end
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  end

private

  def filter_params
    {
      filters: params.slice(:title_or_url, :document_type, :status, :organisation).permit!,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    }
  end

  def update_params(document)
    contents_params = document.document_type.contents.map(&:id)

    params.require(:revision)
      .permit(:update_type, :change_note, :title, :summary, contents: contents_params)
      .tap do |p|
        p[:title] = p[:title]&.strip
        p[:summary] = p[:summary]&.strip
        p[:base_path] = PathGeneratorService.new.path(document, p[:title])
      end
  end
end
