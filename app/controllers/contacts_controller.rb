# frozen_string_literal: true

class ContactsController < ApplicationController
  def search
    @document = Document.find_by_param(params[:id])
    @contacts_by_organisation = ContactsService.new.all_by_organisation
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    render "search_api_down", status: :service_unavailable
  end

  def insert
    document = Document.find_by_param(params[:id])
    redirect_location = edit_document_path(document) + "#body"

    unless params[:contact_id]
      redirect_to redirect_location
      return
    end

    contact_markdown = "[Contact:#{params[:contact_id]}]\n"

    body = document.contents.fetch("body", "").chomp
    document.contents["body"] = if body.present?
                                  "#{body}\n\n#{contact_markdown}"
                                else
                                  contact_markdown
                                end

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "updated_content",
    )

    redirect_to redirect_location
  end
end
