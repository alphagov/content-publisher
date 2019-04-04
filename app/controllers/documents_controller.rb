# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    if filter_params[:filters].empty?
      redirect_to documents_path(organisation: current_user.organisation_content_id)
      return
    end

    filter = EditionFilter.new(filter_params)
    @editions = filter.editions
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @revision = @edition.revision
  end

  def show
    @edition = Edition.find_current(document: params[:document])
  end

  def confirm_delete_draft
    edition = Edition.find_current(document: params[:document])
    redirect_to document_path(edition.document), confirmation: "documents/show/delete_draft"
  end

  def destroy
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      begin
        DeleteDraftService.new(edition.document, current_user).delete

        TimelineEntry.create_for_status_change(entry_type: :draft_discarded,
                                               status: edition.status)

        redirect_to documents_path
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to edition.document, alert_with_description: t("documents.show.flashes.delete_draft_error")
      end
    end
  end

  def update
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(update_params(edition.document))

      add_contact_request = params[:submit] == "add_contact"
      @issues = Requirements::EditPageChecker.new(edition, updater.next_revision)
                                             .pre_preview_issues

      if @issues.any?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("documents.edit.flashes.requirements"),
          "items" => @issues.items,
        }

        render :edit,
               assigns: { edition: edition, revision: updater.next_revision },
               status: :unprocessable_entity
        next
      end

      if updater.changed?
        edition.assign_revision(updater.next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      if add_contact_request
        redirect_to search_contacts_path(edition.document)
      else
        redirect_to edition.document
      end
    end
  end

  def generate_path
    edition = Edition.find_current(document: params[:document])
    base_path = PathGeneratorService.new.path(edition.document, params[:title])
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
