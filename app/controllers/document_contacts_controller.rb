# frozen_string_literal: true

class DocumentContactsController < ApplicationController
  def search
    @document = Document.find_by_param(params[:id])
    @contacts_by_organisation = ContactsService.new.all_by_organisation
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    render "search_api_down", status: :service_unavailable
  end

  def insert
    document = Document.find_by_param(params[:id])
    contact_markdown = "[Contact:#{params.require(:contact_id)}]\n"

    body = document.contents.fetch("body", "").chomp
    document.contents["body"] = if body.present?
                                  "#{body}\n\n#{contact_markdown}"
                                else
                                  contact_markdown
                                end

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "updated_content",
    )

    redirect_to edit_document_path(document) + "#body"
  end
end
