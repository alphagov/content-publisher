# frozen_string_literal: true

module Versioned
  class ContactsController < BaseController
    def search
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:id])
      @contacts_by_organisation = ContactsService.new.all_by_organisation
    rescue GdsApi::BaseError => e
      GovukError.notify(e)
      render "search_api_down", status: :service_unavailable
    end

    def insert
      Versioned::Document.transaction do # rubocop:disable Metrics/BlockLength
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        redirect_location = versioned_edit_document_path(document) + "#body"

        unless params[:contact_id]
          redirect_to redirect_location
          return
        end

        contact_markdown = "[Contact:#{params[:contact_id]}]\n"
        current_edition = document.current_edition

        body = current_edition.contents.fetch("body", "").chomp
        updated_body = if body.present?
                         "#{body}\n\n#{contact_markdown}"
                       else
                         contact_markdown
                       end

        revision = current_edition.build_revision_update(
          { contents: current_edition.contents.merge("body" => updated_body) },
          current_user,
        )

        if revision != current_edition.revision
          current_edition.assign_revision(revision, current_user).save!

          Versioned::TimelineEntry.create_for_revision(
            entry_type: :updated_content,
            edition: current_edition,
          )

          Versioned::PreviewService.new(current_edition).try_create_preview
        end

        redirect_to redirect_location
      end
    end
  end
end
