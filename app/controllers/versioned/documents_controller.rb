# frozen_string_literal: true

module Versioned
  class DocumentsController < ApplicationController
    def index
      filter = Versioned::EditionFilter.new(filter_params)
      @editions = filter.editions
      @filter_params = filter.filter_params
      @sort = filter.sort
    end

    def edit
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:id])
      @revision = @document.current_edition.revision
    end

    def show
      document = Versioned::Document.with_current_edition
                                    .find_by_param(params[:id])
      @edition = document.current_edition
    end

    def confirm_delete_draft
      document = Versioned::Document.with_current_edition
                                    .find_by_param(params[:id])
      redirect_to versioned_document_path(document), confirmation: "versioned/documents/show/delete_draft"
    end

    def destroy
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        begin
          current_edition = document.current_edition
          Versioned::DeleteDraftService.new(document, current_user).delete

          Versioned::TimelineEntry.create_for_status_change(
            entry_type: :draft_discarded,
            status: current_edition.status,
          )

          redirect_to versioned_documents_path
        rescue GdsApi::BaseError => e
          GovukError.notify(e)
          redirect_to document, alert_with_description: t("documents.show.flashes.delete_draft_error")
        end
      end
    end

    def update
      Versioned::Document.transaction do # rubocop:disable Metrics/BlockLength
        @document = Versioned::Document.with_current_edition
                                       .lock
                                       .find_by_param(params[:id])
        current_edition = @document.current_edition
        @revision = current_edition.build_next_revision(update_params(@document),
                                                        current_user)

        add_contact_request = params[:submit] == "add_contact"
        @issues = Versioned::Requirements::EditPageChecker.new(current_edition, @revision)
                                                          .pre_preview_issues

        if @issues.any?
          flash.now["alert_with_items"] = {
            "title" => I18n.t!("documents.edit.flashes.requirements"),
            "items" => @issues.items,
          }

          render :edit
          return
        end

        current_edition.update!(revision: @revision)
        current_edition.update_last_edited_at(current_user)

        Versioned::TimelineEntry.create_for_revision(
          entry_type: :updated_content,
          edition: current_edition,
        )

        Versioned::PreviewService.new(current_edition).try_create_preview

        if add_contact_request
          redirect_to versioned_search_contacts_path(@document)
        else
          redirect_to @document
        end
      end
    end

    def generate_path
      document = Versioned::Document.find_by_param(params[:id])
      base_path = Versioned::PathGeneratorService.new.path(document, params[:title])
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
          p[:base_path] = Versioned::PathGeneratorService.new.path(document, p[:title])
        end
    end
  end
end
