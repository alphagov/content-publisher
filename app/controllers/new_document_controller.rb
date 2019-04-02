# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = Supertype.all
  end

  def choose_document_type
    if params[:supertype].blank?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("new_document.choose_supertype.flashes.requirements"),
        "items" => supertype_issues.items,
      }

      render :choose_supertype,
             assigns: { issues: supertype_issues, supertypes: Supertype.all },
             status: :unprocessable_entity
      return
    end

    @supertype = Supertype.find(params[:supertype])

    if @supertype.managed_elsewhere
      redirect_to @supertype.managed_elsewhere_url
      return
    end
  end

  def create
    if params[:document_type].blank?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("new_document.choose_document_type.flashes.requirements"),
        "items" => document_type_issues.items,
      }

      render :choose_document_type,
             assigns: { issues: document_type_issues,
                        supertype: Supertype.find(params[:supertype]) },
             status: :unprocessable_entity
      return
    end

    document_type = DocumentType.find(params[:document_type])

    if document_type.managed_elsewhere
      redirect_to document_type.managed_elsewhere_url
      return
    end

    document = Document.create_initial(document_type_id: params[:document_type],
                                       tags: default_tags,
                                       user: current_user)

    TimelineEntry.create_for_status_change(entry_type: :created,
                                           status: document.current_edition.status)

    redirect_to edit_document_path(document)
  end

private

  def default_tags
    current_user.organisation_content_id ? { primary_publishing_organisation: [current_user.organisation_content_id] } : {}
  end

  def document_type_issues
    @document_type_issues ||= Requirements::CheckerIssues.new([
      Requirements::Issue.new(:document_type, :not_selected),
    ])
  end

  def supertype_issues
    @supertype_issues ||= Requirements::CheckerIssues.new([
      Requirements::Issue.new(:supertype, :not_selected),
    ])
  end
end
