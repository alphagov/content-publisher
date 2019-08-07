# frozen_string_literal: true

class ContactsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    @contacts_by_organisation = Contacts.new.all_by_organisation
    render layout: rendering_context
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    render "index_api_down", layout: rendering_context
  end
end
