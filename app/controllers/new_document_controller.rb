# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_document_type
    result = NewDocument::ChooseSupertypeInteractor.call(params: params, user: current_user)
    issues, @supertype = result.to_h.values_at(:issues, :supertype)

    if result.issues
      flash.now["requirements"] = { "items" => issues.items }

      render :choose_supertype,
             assigns: { issues: issues },
             status: :unprocessable_entity
    elsif @supertype.managed_elsewhere
      redirect_to @supertype.managed_elsewhere_url
    end
  end

  def create
    result = NewDocument::CreateInteractor.call(params: params, user: current_user)
    issues, supertype, document_type, document = result.to_h.values_at(:issues,
                                                                       :supertype,
                                                                       :document_type,
                                                                       :document)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :choose_document_type,
             assigns: { issues: issues, supertype: supertype },
             status: :unprocessable_entity
    elsif result.managed_elsewhere
      redirect_to document_type.managed_elsewhere_url
    else
      redirect_to edit_document_path(document)
    end
  end
end
