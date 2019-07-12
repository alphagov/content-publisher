# frozen_string_literal: true

class ContactsController < ApplicationController
  def search
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    @contacts_by_organisation = ContactsService.new.all_by_organisation
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    render "search_api_down", status: :service_unavailable
  end

  def insert
    Contacts::InsertInteractor.call(params: params, user: current_user)

    redirect_to edit_document_path(params[:document], anchor: "body")
  end
end
