# frozen_string_literal: true

class ContactsController < ApplicationController
  def search
    @edition = Edition.find_current(document: params[:document])
    @contacts_by_organisation = ContactsService.new.all_by_organisation
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    render "search_api_down", status: :service_unavailable
  end

  def insert
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      redirect_location = edit_document_path(edition.document) + "#body"

      if params[:contact_id].empty?
        redirect_to redirect_location
        next
      end

      contact_markdown = "[Contact:#{params[:contact_id]}]\n"
      current_revision = edition.revision

      body = current_revision.contents.fetch("body", "").chomp
      updated_body = if body.present?
                       "#{body}\n\n#{contact_markdown}"
                     else
                       contact_markdown
                     end

      next_revision = current_revision.build_revision_update(
        { contents: current_revision.contents.merge("body" => updated_body) },
        current_user,
      )

      if next_revision != current_revision
        edition.assign_revision(next_revision, current_user).save!

        TimelineEntry.create_for_revision(entry_type: :updated_content,
                                          edition: edition)

        PreviewService.new(edition).try_create_preview
      end

      redirect_to redirect_location
    end
  end
end
