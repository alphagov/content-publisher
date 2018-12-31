# frozen_string_literal: true

module Versioned
  class ContactsController < ApplicationController
    def search
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:id])
      @contacts_by_organisation = ContactsService.new.all_by_organisation
    rescue GdsApi::BaseError => e
      GovukError.notify(e)
      render "search_api_down", status: :service_unavailable
    end

    def insert
      Versioned::Document.transaction do
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

        revision = current_edition.build_next_revision(
          { contents: current_edition.contents.merge("body" => updated_body) },
          current_user,
        )

        current_edition.update!(revision: revision)
        current_edition.update_last_edited_at(current_user)

        PreviewService.new(current_edition).try_create_preview

        # TODO: Add timeline entry

        redirect_to redirect_location
      end
    end
  end
end
